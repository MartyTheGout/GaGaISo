//
//  ChatModel.swift
//  GaGaISo
//
//  Created by marty.academy on 5/26/25.
//

import Foundation

// MARK: - Local Chat Models
struct ChatRoom: Identifiable, Codable {
    let id: String // room_id
    let participants: [Participant]
    var lastMessage: ChatMessage?
    var unreadCount: Int = 0
    let createdAt: Date
    var updatedAt: Date
    
    // 상대방 정보 (1:1 채팅 기준)
    var otherParticipant: Participant? {
        // 현재 사용자가 아닌 참가자 반환
        participants.first { $0.userId != getCurrentUserId() }
    }
    
    private func getCurrentUserId() -> String {
        // 현재 사용자 ID 반환 로직
        return "" // 실제 구현 필요
    }
}

struct ChatMessage: Identifiable, Codable {
    let id: String // chat_id
    let roomId: String
    let content: String
    let senderId: String
    let senderNick: String
    let senderProfileImage: String?
    let files: [String]?
    let createdAt: Date
    var isRead: Bool = false
    var isSent: Bool = true // 전송 상태
    
    // 내가 보낸 메시지인지 확인
    var isMyMessage: Bool {
        senderId == getCurrentUserId()
    }
    
    private func getCurrentUserId() -> String {
        // 현재 사용자 ID 반환 로직
        return "" // 실제 구현 필요
    }
}

// MARK: - Socket Message Models
struct SocketMessage: Codable {
    let type: SocketMessageType
    let data: SocketMessageData
}

enum SocketMessageType: String, Codable {
    case newMessage = "new_message"
    case messageRead = "message_read"
    case userJoined = "user_joined"
    case userLeft = "user_left"
}

struct SocketMessageData: Codable {
    let chatId: String?
    let roomId: String
    let content: String?
    let senderId: String?
    let senderNick: String?
    let createdAt: String?
    let files: [String]?
    
    enum CodingKeys: String, CodingKey {
        case chatId = "chat_id"
        case roomId = "room_id"
        case content
        case senderId = "sender_id"
        case senderNick = "sender_nick"
        case createdAt = "created_at"
        case files
    }
}
