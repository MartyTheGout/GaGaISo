//
//  SocketChatMessageDTO.swift
//  GaGaISo
//
//  Created by marty.academy on 6/3/25.
//

import Foundation

struct SocketChatMessageDTO: Codable {
    let chatId: String
    let roomId: String
    let content: String
    let createdAt: String
    let files: [String]
    let sender: SocketSender
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case chatId = "chat_id"
        case roomId = "room_id"
        case content
        case createdAt
        case files
        case sender
        case updatedAt
    }
    
    func toChatMessage() -> ChatMessage {
        let dateFormatter = ISO8601DateFormatter()
        let createdAtDate = dateFormatter.date(from: createdAt) ?? Date()

        
        return ChatMessage(
            id: chatId,
            roomId: roomId,
            content: content,
            senderId: sender.userId,
            senderNick: sender.nick,
            senderProfileImage: nil, // 소켓 데이터에 없음
            files: files.isEmpty ? nil : files,
            createdAt: createdAtDate,
            isRead: false,
            isSent: true
        )
    }
}

struct SocketSender: Codable {
    let nick: String
    let userId: String
    
    enum CodingKeys: String, CodingKey {
        case nick
        case userId = "user_id"
    }
}
