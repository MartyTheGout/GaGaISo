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
    
    var otherParticipant: Participant? {
        participants.first { $0.userId != RealmCurrentUser.getCurrentUserId() }
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
    var isSent: Bool = true
    var isMyMessage: Bool
}
