//
//  Objects.swift
//  GaGaISo
//
//  Created by marty.academy on 5/27/25.
//

import Foundation
import RealmSwift

class RealmChatRoom: Object, ObjectKeyIdentifiable {
    @Persisted var id: String = ""
    @Persisted var participants: List<RealmParticipant>
    @Persisted var lastMessageId: String = ""
    @Persisted var unreadCount: Int = 0
    @Persisted var createdAt: Date = Date()
    @Persisted var updatedAt: Date = Date()
    
    override static func primaryKey() -> String? { "id" }
    
    var lastMessage: RealmChatMessage? {
        guard !lastMessageId.isEmpty else { return nil }
        return realm?.object(ofType: RealmChatMessage.self, forPrimaryKey: lastMessageId)
    }
}

class RealmParticipant: Object, ObjectKeyIdentifiable {
    @Persisted var userId: String = ""
    @Persisted var nick: String = ""
    @Persisted var profileImage: String = ""
    
    override static func primaryKey() -> String? { "userId" }
}

class RealmChatMessage: Object, ObjectKeyIdentifiable {
    @Persisted var id: String = ""
    @Persisted var roomId: String = ""
    @Persisted var content: String = ""
    @Persisted var senderId: String = ""
    @Persisted var senderNick: String = ""
    @Persisted var senderProfileImage: String = ""
    @Persisted var files: List<String>
    @Persisted var createdAt: Date = Date()
    @Persisted var isRead: Bool = false
    @Persisted var isSent: Bool = true
    
    override static func primaryKey() -> String? { "id" }
    
    var isMyMessage: Bool {
        senderId == getCurrentUserId()
    }
    
    private func getCurrentUserId() -> String {
        // 실제 구현 필요
        return ""
    }
}
