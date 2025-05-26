//
//  ChatRoomDTO.swift
//  GaGaISo
//
//  Created by marty.academy on 5/26/25.
//

import Foundation

// MARK: - Chat Room Response DTO
struct ChatRoomDTO: Codable {
    let roomId: String
    let createdAt: String
    let updatedAt: String
    let participants: [Participant]
    let lastChat: LastChatDTO?
    
    enum CodingKeys: String, CodingKey {
        case roomId = "room_id"
        case createdAt, updatedAt, participants
        case lastChat = "lastChat"
    }
}

struct Participant: Codable {
    let userId: String
    let nick: String
    let profileImage: String?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case nick
        case profileImage = "profileImage"
    }
}

struct LastChatDTO: Codable {
    let chatId: String
    let roomId: String
    let content: String
    let createdAt: String
    let updatedAt: String
    let sender: Participant
    let files: [String]?
    
    enum CodingKeys: String, CodingKey {
        case chatId = "chat_id"
        case roomId = "room_id"
        case content, createdAt, updatedAt, sender, files
    }
}
