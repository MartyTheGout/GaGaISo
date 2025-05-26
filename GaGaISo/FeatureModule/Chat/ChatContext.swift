//
//  ChatContext.swift
//  GaGaISo
//
//  Created by marty.academy on 5/27/25.
//

import Foundation
import Combine
import RealmSwift

class ChatContext: ObservableObject {
    private let chatService: ChatService
    private let realm: Realm
    private var cancellables = Set<AnyCancellable>()
    
    // Published properties
    @Published private(set) var chatRooms: [ChatRoom] = []
    @Published private(set) var currentMessages: [ChatMessage] = []
    @Published private(set) var currentRoomId: String?
    @Published private(set) var totalUnreadCount: Int = 0
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var connectionStatus: SocketConnectionStatus = .disconnected
    @Published var errorMessage: String?
    
    // Realm 관찰자들
    private var roomsToken: NotificationToken?
    private var messagesToken: NotificationToken?
    
    init(chatService: ChatService) {
        self.chatService = chatService
        self.realm = try! Realm()
        
        setupRealmObservers()
        setupServiceObservers()
        loadInitialData()
    }
    
    deinit {
        roomsToken?.invalidate()
        messagesToken?.invalidate()
    }
    
    // MARK: - Setup
    private func setupRealmObservers() {
        // 채팅방 목록 관찰
        let realmRooms = realm.objects(RealmChatRoom.self).sorted(byKeyPath: "updatedAt", ascending: false)
        
        roomsToken = realmRooms.observe { [weak self] changes in
            switch changes {
            case .initial(let rooms):
                self?.chatRooms = rooms.map { self?.mapToChatRoom(from: $0) }.compactMap { $0 }
                self?.updateTotalUnreadCount()
            case .update(let rooms, _, _, _):
                self?.chatRooms = rooms.map { self?.mapToChatRoom(from: $0) }.compactMap { $0 }
                self?.updateTotalUnreadCount()
            case .error(let error):
                print("Realm 관찰 오류: \(error)")
            }
        }
    }
    
    private func setupServiceObservers() {
        // Socket 연결 상태
        chatService.$connectionStatus
            .assign(to: &$connectionStatus)
        
        // 새 메시지 수신
        chatService.$newMessage
            .compactMap { $0 }
            .sink { [weak self] message in
                self?.handleNewMessage(message)
            }
            .store(in: &cancellables)
    }
    
    private func loadInitialData() {
        loadChatRooms()
        chatService.connectSocket()
    }
    
    // MARK: - Public Methods
    func createOrGetChatRoom(with userId: String) async -> ChatRoom? {
        let result = await chatService.createOrGetChatRoom(with: userId)
        
        switch result {
        case .success(let room):
            saveChatRoom(room)
            return room
        case .failure(let error):
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
            return nil
        }
    }
    
    @MainActor
    func enterChatRoom(_ roomId: String) async {
        currentRoomId = roomId
        
        // 메시지 관찰 시작
        observeMessages(for: roomId)
        
        // Socket 방 입장
        chatService.joinRoom(roomId)
        
        // 읽음 처리
        markMessagesAsRead(in: roomId)
    }
    
    @MainActor
    func leaveChatRoom() {
        guard let roomId = currentRoomId else { return }
        
        chatService.leaveRoom(roomId)
        currentRoomId = nil
        currentMessages = []
        messagesToken?.invalidate()
    }
    
    func sendMessage(content: String, files: [String]? = nil) async -> Bool {
        guard let roomId = currentRoomId else { return false }
        
        let result = await chatService.sendMessage(roomId: roomId, content: content, files: files)
        
        switch result {
        case .success(let message):
            saveMessage(message)
            return true
        case .failure(let error):
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
            return false
        }
    }
    
    // MARK: - Private Methods
    private func observeMessages(for roomId: String) {
        let realmMessages = realm.objects(RealmChatMessage.self)
            .filter("roomId == %@", roomId)
            .sorted(byKeyPath: "createdAt", ascending: true)
        
        messagesToken = realmMessages.observe { [weak self] changes in
            switch changes {
            case .initial(let messages):
                DispatchQueue.main.async {
                    self?.currentMessages = messages.map { self?.mapToChatMessage(from: $0) }.compactMap { $0 }
                }
            case .update(let messages, _, _, _):
                DispatchQueue.main.async {
                    self?.currentMessages = messages.map { self?.mapToChatMessage(from: $0) }.compactMap { $0 }
                }
            case .error(let error):
                print("메시지 관찰 오류: \(error)")
            }
        }
    }
    
    private func handleNewMessage(_ message: ChatMessage) {
        saveMessage(message)
        
        // 현재 방이 아니면 미읽음 처리
        if message.roomId != currentRoomId {
            incrementUnreadCount(for: message.roomId)
        }
    }
    
    private func loadChatRooms() {
        Task {
            let result = await chatService.getChatRooms()
            
            switch result {
            case .success(let rooms):
                for room in rooms {
                    saveChatRoom(room)
                }
            case .failure(let error):
                await MainActor.run {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Realm Operations
    private func saveChatRoom(_ room: ChatRoom) {
        try! realm.write {
            let realmRoom = RealmChatRoom()
            realmRoom.id = room.id
            
            let realmParticipants = room.participants.map { participant in
                let realmParticipant = RealmParticipant()
                realmParticipant.userId = participant.userId
                realmParticipant.nick = participant.nick
                realmParticipant.profileImage = participant.profileImage ?? ""
                return realmParticipant
            }
            realmRoom.participants.append(objectsIn: realmParticipants)
            
            realmRoom.lastMessageId = room.lastMessage?.id ?? ""
            realmRoom.unreadCount = room.unreadCount
            realmRoom.createdAt = room.createdAt
            realmRoom.updatedAt = room.updatedAt
            
            realm.add(realmRoom, update: .modified)
        }
    }
    
    private func saveMessage(_ message: ChatMessage) {
        try! realm.write {
            let realmMessage = RealmChatMessage()
            realmMessage.id = message.id
            realmMessage.roomId = message.roomId
            realmMessage.content = message.content
            realmMessage.senderId = message.senderId
            realmMessage.senderNick = message.senderNick
            realmMessage.senderProfileImage = message.senderProfileImage ?? ""
            
            if let files = message.files {
                realmMessage.files.append(objectsIn: files)
            }
            
            realmMessage.createdAt = message.createdAt
            realmMessage.isRead = message.isRead
            realmMessage.isSent = message.isSent
            
            realm.add(realmMessage, update: .modified)
            
            // 채팅방의 마지막 메시지도 업데이트
            if let room = realm.object(ofType: RealmChatRoom.self, forPrimaryKey: message.roomId) {
                room.lastMessageId = message.id
                room.updatedAt = message.createdAt
            }
        }
    }
    
    private func markMessagesAsRead(in roomId: String) {
        try! realm.write {
            let unreadMessages = realm.objects(RealmChatMessage.self)
                .filter("roomId == %@ AND isRead == false AND senderId != %@", roomId, getCurrentUserId())
            
            for message in unreadMessages {
                message.isRead = true
            }
            
            // 채팅방 미읽음 개수 초기화
            if let room = realm.object(ofType: RealmChatRoom.self, forPrimaryKey: roomId) {
                room.unreadCount = 0
            }
        }
    }
    
    private func incrementUnreadCount(for roomId: String) {
        try! realm.write {
            if let room = realm.object(ofType: RealmChatRoom.self, forPrimaryKey: roomId) {
                room.unreadCount += 1
            }
        }
    }
    
    private func updateTotalUnreadCount() {
        let total: Int = realm.objects(RealmChatRoom.self).sum(ofProperty: "unreadCount")
        DispatchQueue.main.async {
            self.totalUnreadCount = total
        }
    }
    
    // MARK: - Mapping
    private func mapToChatRoom(from realmRoom: RealmChatRoom) -> ChatRoom {
        let participants = Array(realmRoom.participants.map { realmParticipant in
            Participant(
                userId: realmParticipant.userId,
                nick: realmParticipant.nick,
                profileImage: realmParticipant.profileImage.isEmpty ? nil : realmParticipant.profileImage
            )
        })
        
        let lastMessage = realmRoom.lastMessage.map { mapToChatMessage(from: $0) }
        
        return ChatRoom(
            id: realmRoom.id,
            participants: participants,
            lastMessage: lastMessage,
            unreadCount: realmRoom.unreadCount,
            createdAt: realmRoom.createdAt,
            updatedAt: realmRoom.updatedAt
        )
    }
    
    private func mapToChatMessage(from realmMessage: RealmChatMessage) -> ChatMessage {
        ChatMessage(
            id: realmMessage.id,
            roomId: realmMessage.roomId,
            content: realmMessage.content,
            senderId: realmMessage.senderId,
            senderNick: realmMessage.senderNick,
            senderProfileImage: realmMessage.senderProfileImage.isEmpty ? nil : realmMessage.senderProfileImage,
            files: realmMessage.files.isEmpty ? nil : Array(realmMessage.files),
            createdAt: realmMessage.createdAt,
            isRead: realmMessage.isRead,
            isSent: realmMessage.isSent
        )
    }
    
    private func getCurrentUserId() -> String {
        // 실제 구현 필요
        return ""
    }
    
    func connectSocket() {
        chatService.connectSocket()
    }

    func disconnectSocket() {
        chatService.disconnectSocket()
    }
}

extension ChatContext {
    func getChatRoom(by roomId: String) -> ChatRoom? {
        return chatRooms.first { $0.id == roomId }
    }
    
    func refreshChatRooms() async {
        await MainActor.run {
            isLoading = true
        }
        
        let result = await chatService.getChatRooms()
        
        await MainActor.run {
            switch result {
            case .success(let rooms):
                for room in rooms {
                    saveChatRoom(room)
                }
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    func deleteChatRoom(_ roomId: String) async {
        // 실제 서버 API 호출이 필요하면 여기에 추가
        
        // 로컬에서만 삭제하는 경우
        try! realm.write {
            if let roomToDelete = realm.object(ofType: RealmChatRoom.self, forPrimaryKey: roomId) {
                // 해당 방의 모든 메시지도 삭제
                let messagesToDelete = realm.objects(RealmChatMessage.self).filter("roomId == %@", roomId)
                realm.delete(messagesToDelete)
                realm.delete(roomToDelete)
            }
        }
    }
    
    func loadChatRoomsPublic() async {
        loadChatRooms()
    }
}
