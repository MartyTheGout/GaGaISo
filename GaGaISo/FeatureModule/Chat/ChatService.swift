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
        let result = await networkManager.request(ChatRouter.v1SendMessage(roomId: roomId, message: content, fileURL: files ?? []), type: LastChatDTO.self)
        dump(result)
        return result.map { mapToChatMessage(from: $0) }
    }
    
    func connectSocket(roomId: String) {
        setupSocket(roomId: roomId)
        socket?.connect()
    }
    
    func disconnectSocket() {
        socket?.disconnect()
    }
    
    private func setupSocket(roomId: String) {
        guard let url = URL(string: ExternalDatasource.pickup.baseURLString) else { return }
        
        manager = SocketManager(socketURL: url, config: [
            .compress,
            .extraHeaders(
                [
                    "Authorization": networkManager.getAccessToken() ?? "",
                    "SeSACKey": APIKey.PICKUP
                ]
            )
        ])
        
        socket = manager?.socket(forNamespace: "/chats-\(roomId)")
        
        socket?.on(clientEvent: .connect) { [weak self] _, _ in
            DispatchQueue.main.async {
                print("socket connection created")
                self?.connectionStatus = .connected
            }
        }
        
        socket?.on(clientEvent: .disconnect) { [weak self] _, _ in
            DispatchQueue.main.async {
                print("socket connection disconnected")
                self?.connectionStatus = .disconnected
            }
        }
        
        socket?.on(clientEvent: .error) { [weak self] data, _ in
            DispatchQueue.main.async {
                self?.connectionStatus = .error(data.first as? String ?? "Unknown error")
            }
        }
        
        socket?.on("chat") { data, _ in
            guard let messageDict = data.first as? [String: Any] else {
                print("[Socket Message Reciever Error] Failed to convert Dictionary from first Any")
                dump(data)
                return
            }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: messageDict)
                let socketMessage = try JSONDecoder().decode(SocketChatMessageDTO.self, from: jsonData)
                let chateMessage = socketMessage.toChatMessage()
                
                DispatchQueue.main.async { [weak self] in
                    print("Success converting, saving to ChatService's property")
                    self?.newMessage = chateMessage
                }
            } catch {
                print("[Socket Message Reciever Error] Failed to convert ChatMessage from JSONObject")
                dump(error)
            }
        }
    }
}

extension ChatService {
    private func mapToChatRoom(from dto: ChatRoomDTO) -> ChatRoom {
        let dateFormatter = ISO8601DateFormatter()
        let createdAt = dateFormatter.date(from: dto.createdAt) ?? Date()
        let updatedAt = dateFormatter.date(from: dto.updatedAt) ?? Date()
        var chatMessage: ChatMessage?
        
        if let lastChat = dto.lastChat {
            chatMessage = mapToChatMessage(from: lastChat)
        } else {
            chatMessage = nil
        }
        
        return ChatRoom(
            id: dto.roomId,
            participants: dto.participants,
            lastMessage: chatMessage,
            unreadCount: 0,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
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
