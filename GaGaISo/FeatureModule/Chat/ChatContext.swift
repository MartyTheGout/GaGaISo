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
    private var cancellables = Set<AnyCancellable>()
    
    @Published private(set) var chatRooms: [ChatRoom] = []
    @Published private(set) var currentMessages: [ChatMessage] = []
    @Published private(set) var currentRoomId: String?
    @Published private(set) var totalUnreadCount: Int = 0
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var connectionStatus: SocketConnectionStatus = .disconnected
    @Published var errorMessage: String?
    
    private var roomsToken: NotificationToken?
    private var messagesToken: NotificationToken?
    
    init(chatService: ChatService) {
        self.chatService = chatService
        
        setupRealmObservers()
        setupServiceObservers()
        loadInitialData()
    }
    
    deinit {
        roomsToken?.invalidate()
        messagesToken?.invalidate()
    }
    
    // MARK: - ChatContext Entire Setup
    private func setupRealmObservers() {
        let realm = try! Realm()
        
        let realmRooms = realm.objects(RealmChatRoom.self).sorted(byKeyPath: "updatedAt", ascending: false)
        
        roomsToken = realmRooms.observe { [weak self] changes in
            switch changes {
            case .initial(let rooms):
                self?.chatRooms = rooms.map { self?.mapToChatRoom(from: $0) }.compactMap { $0 }
                self?.updateTotalUnreadCount()
            case .update(let rooms, let deletions, let insertions, let modifications):
                
                guard !deletions.isEmpty || !insertions.isEmpty || !modifications.isEmpty else { return }
                
                print("Realm Write Tracking - Delete: \(deletions.count), Insert: \(insertions.count), Modify: \(modifications.count)")
                
                self?.chatRooms = rooms.map { self?.mapToChatRoom(from: $0) }.compactMap { $0 }
                self?.updateTotalUnreadCount()
                
            case .error(let error):
                print("Realm error : \(error)")
            }
        }
    }
    
    private func setupServiceObservers() {
        chatService.$connectionStatus
            .assign(to: &$connectionStatus)
        
        chatService.$newMessage
            .compactMap { $0 }
            .sink { [weak self] message in
                self?.handleNewMessage(message)
            }
            .store(in: &cancellables)
    }
    
    private func loadInitialData() {
        loadChatRooms()
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
                    errorMessage = error.localizedDescription + "\(#function)"
                }
            }
        }
    }
    
    // MARK: - ChatContext Action
    func createOrGetChatRoom(with userId: String) async -> ChatRoom? {
        let result = await chatService.createOrGetChatRoom(with: userId)
        
        switch result {
        case .success(let room):
            saveChatRoom(room)
            return room
        case .failure(let error):
            await MainActor.run {
                print(#function)
                errorMessage = error.localizedDescription + "\(#function)"
            }
            return nil
        }
    }
    
    @MainActor
    func enterChatRoom(_ roomId: String) {
        
        currentRoomId = roomId
        
        observeMessages(for: roomId)
        
        connectSocket(rommId: roomId)
        
        markMessagesAsRead(in: roomId)
    }
    
    @MainActor
    func leaveChatRoom() {
        guard let _ = currentRoomId else { return }
        
        disconnectSocket()
        
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
    
    //**Currently only handle new message from the existing socket connection : lately can be updated to have push notification here.
    private func handleNewMessage(_ message: ChatMessage) {
        saveMessage(message)
    }
}

// MARK: - Realm Operations
extension ChatContext {
    private func observeMessages(for roomId: String) {
        let realm = try! Realm()
        
        let realmMessages = realm.objects(RealmChatMessage.self)
            .filter("roomId == %@", roomId)
            .sorted(byKeyPath: "createdAt", ascending: true)
        
        messagesToken = realmMessages.observe { [weak self] changes in
            switch changes {
            case .initial(let messages):
                DispatchQueue.main.async {
                    self?.currentMessages = messages.map { self?.mapToChatMessage(from: $0) }.compactMap { $0 }
                }
            case .update(let messages, let deletions, let insertions, let modifications):
                guard !deletions.isEmpty || !insertions.isEmpty || !modifications.isEmpty else { return }
                
                print("Realm Write Tracking - Delete: \(deletions.count), Insert: \(insertions.count), Modify: \(modifications.count)")
                
                DispatchQueue.main.async {
                    self?.currentMessages = messages.map { self?.mapToChatMessage(from: $0) }.compactMap { $0 }
                }
    
            case .error(let error):
                print("Realm Error: \(error)")
            }
        }
    }
    
    // Save loaded ChatRoom when realm has no updated data. different updated data.
    private func saveChatRoom(_ room: ChatRoom) {
        let realm = try! Realm()
        
        let realmRoom = realm.objects(RealmChatRoom.self).where { $0.id == room.id }.first
        
        // Update Condition: 1) There is no same data on Realm, 2) There is different lastMessage.id
        let shouldUpdate: Bool
        if let existingRoom = realmRoom {
            shouldUpdate = existingRoom.lastMessageId != (room.lastMessage?.id ?? "")
        } else {
            shouldUpdate = true
        }
        
        guard shouldUpdate else {
            return
        }
        
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
            
            realm.add(realmRoom, update: .modified) // update option works, when same primary key record exists
            
            if let lastMessage = room.lastMessage {
                saveMessageOnly(lastMessage, in: realm)
            }
        }
    }
    
    // saveMessageOnly is required when chatRoomUpdate happens firstly.
    // But when just message updated, corresponding chat room update is also required.
    private func saveMessageOnly(_ message: ChatMessage, in realm: Realm) {
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
    }
    
    private func saveMessage(_ message: ChatMessage, shouldUpdateRoom: Bool = true) {
        let realm = try! Realm()
        
        try! realm.write {
            saveMessageOnly(message, in: realm)
            
            if shouldUpdateRoom {
                updateChatRoomLastMessage(roomId: message.roomId, messageId: message.id, updatedAt: message.createdAt, in: realm)
            }
        }
    }
    
    private func updateChatRoomLastMessage(roomId: String, messageId: String, updatedAt: Date, in realm: Realm) {
        if let room = realm.object(ofType: RealmChatRoom.self, forPrimaryKey: roomId) {
            room.lastMessageId = messageId
            room.updatedAt = updatedAt
        }
    }
    
    private func markMessagesAsRead(in roomId: String) {
        let realm = try! Realm()
        
        try! realm.write {
            let unreadMessages = realm.objects(RealmChatMessage.self)
                .filter("roomId == %@ AND isRead == false", roomId)
            
            for message in unreadMessages {
                message.isRead = true
            }
            
            if let room = realm.object(ofType: RealmChatRoom.self, forPrimaryKey: roomId) {
                room.unreadCount = 0
            }
        }
    }
    
    private func incrementUnreadCount(for roomId: String) {
        let realm = try! Realm()
        
        try! realm.write {
            if let room = realm.object(ofType: RealmChatRoom.self, forPrimaryKey: roomId) {
                room.unreadCount += 1
            }
        }
    }
    
    private func updateTotalUnreadCount() {
        let realm = try! Realm()
        
        let total: Int = realm.objects(RealmChatRoom.self).sum(ofProperty: "unreadCount")
        DispatchQueue.main.async {
            self.totalUnreadCount = total
        }
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
                errorMessage = error.localizedDescription + "\(#function)"
            }
            isLoading = false
        }
    }
    
    func deleteChatRoom(_ roomId: String) {
        let realm = try! Realm()
        
        try! realm.write {
            if let roomToDelete = realm.object(ofType: RealmChatRoom.self, forPrimaryKey: roomId) {
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

// MARK: - Mapping
extension ChatContext {
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
}

//MARK: - Socket
extension ChatContext {
    func connectSocket(rommId: String) {
        chatService.connectSocket(roomId: rommId)
    }
    
    func disconnectSocket() {
        chatService.disconnectSocket()
    }
}
