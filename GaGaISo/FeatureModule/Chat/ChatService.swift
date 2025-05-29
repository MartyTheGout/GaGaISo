//
//  ㅠ.swift
//  GaGaISo
//
//  Created by marty.academy on 5/27/25.
//

// MARK: - Realm Models
import Foundation
import SocketIO

class ChatService: ObservableObject {
    private let networkManager: StrategicNetworkHandler
    private var manager: SocketManager?
    private var socket: SocketIOClient?
    
    @Published var newMessage: ChatMessage?
    @Published var connectionStatus: SocketConnectionStatus = .disconnected
    
    
    init(networkManager: StrategicNetworkHandler) {
        self.networkManager = networkManager
        setupSocket()
    }
    
    func createOrGetChatRoom(with userId: String) async -> Result<ChatRoom, APIError> {
        let result = await networkManager.request(ChatRouter.v1CreateChat(opponent: userId), type: ChatRoomDTO.self)
        
        return result.map { mapToChatRoom(from: $0) }
    }
    
    func getChatRooms() async -> Result<[ChatRoom], APIError> {
        let result = await networkManager.request(
            ChatRouter.v1ListChat,
            type: ChatRoomListDTO.self
        )
        return result.map { $0.data.map { mapToChatRoom(from: $0) } }
    }
    
    func sendMessage(roomId: String, content: String, files: [String]?) async -> Result<ChatMessage, APIError> {
        
        socket?.emit("message", content)
        
        let result = await networkManager.request(ChatRouter.v1SendMessage(roomId: roomId, message: content, fileURL: files ?? []), type: LastChatDTO.self)
        
        return result.map { mapToChatMessage(from: $0) }
    }
    
    // Socket 관련
    func connectSocket() {
        socket?.connect()
    }
    
    func disconnectSocket() {
        socket?.disconnect()
    }
    
    func joinRoom(_ roomId: String) {
        socket?.emit("join_room", roomId)
    }
    
    func leaveRoom(_ roomId: String) {
        socket?.emit("leave_room", roomId)
    }
    
    private func setupSocket() {
        guard let url = URL(string: ExternalDatasource.pickup.baseURLString) else { return }
        
        manager = SocketManager(socketURL: url, config: [
            .extraHeaders(
                [
                    "Authorization": "\(networkManager.getAccessToken())",
                    "SeSACKey": APIKey.PICKUP
                ]
            )
        ])
        
        socket = manager?.defaultSocket
        
        // 연결 상태 모니터링
        socket?.on(clientEvent: .connect) { [weak self] _, _ in
            DispatchQueue.main.async {
                print("socket connection created")
                self?.connectionStatus = .connected
            }
        }
        
        socket?.on(clientEvent: .disconnect) { [weak self] _, _ in
            DispatchQueue.main.async {
                self?.connectionStatus = .disconnected
            }
        }
        
        socket?.on(clientEvent: .error) { [weak self] data, _ in
            DispatchQueue.main.async {
                self?.connectionStatus = .error(data.first as? String ?? "Unknown error")
            }
        }
        
        socket?.on("message") { [weak self] data, _ in
            dump(data)
//            DispatchQueue.main.async {
//                self?.newMessage = data.first as? String?
//            }
        }
    }
    
    private func mapToChatRoom(from dto: ChatRoomDTO) -> ChatRoom {
        return ChatRoom(id: dto.roomId, participants: dto.participants, lastMessage: nil, unreadCount: 0, createdAt: Date(), updatedAt: Date())
    }
    
    private func mapToChatMessage(from dto: LastChatDTO) -> ChatMessage {
        let dateFormatter = ISO8601DateFormatter()
        let createdAt = dateFormatter.date(from: dto.createdAt) ?? Date()
        
        return ChatMessage(
            id: dto.chatId,
            roomId: dto.roomId,
            content: dto.content,
            senderId: dto.sender.userId,
            senderNick: dto.sender.nick,
            senderProfileImage: dto.sender.profileImage,
            files: dto.files,
            createdAt: createdAt,
            isRead: false,
            isSent: true
        )
    }
}

enum SocketConnectionStatus {
    case connected, disconnected, connecting, error(String)
}
