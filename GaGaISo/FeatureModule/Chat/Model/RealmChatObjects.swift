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
    
    convenience init(from chatRoom: ChatRoom) {
        self.init()
        self.id = chatRoom.id
        
        let realmParticipants = chatRoom.participants.map { participant in
            RealmParticipant(from: participant)
        }
        self.participants.append(objectsIn: realmParticipants)
        
        self.lastMessageId = chatRoom.lastMessage?.id ?? ""
        self.unreadCount = chatRoom.unreadCount
        self.createdAt = chatRoom.createdAt
        self.updatedAt = chatRoom.updatedAt
    }
    
    convenience init(
        id: String,
        participants: [RealmParticipant],
        lastMessageId: String = "",
        unreadCount: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.init()
        self.id = id
        self.participants.append(objectsIn: participants)
        self.lastMessageId = lastMessageId
        self.unreadCount = unreadCount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

class RealmParticipant: Object, ObjectKeyIdentifiable {
    @Persisted var userId: String = ""
    @Persisted var nick: String = ""
    @Persisted var profileImage: String = ""
    
    override static func primaryKey() -> String? { "userId" }
    
    convenience init(from participant: Participant) {
        self.init()
        self.userId = participant.userId
        self.nick = participant.nick
        self.profileImage = participant.profileImage ?? ""
    }
    
    convenience init(
        userId: String,
        nick: String,
        profileImage: String = ""
    ) {
        self.init()
        self.userId = userId
        self.nick = nick
        self.profileImage = profileImage
    }
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
    @Persisted var isMine: Bool
    
    override static func primaryKey() -> String? { "id" }
    convenience init(from chatMessage: ChatMessage) {
        self.init()
        self.id = chatMessage.id
        self.roomId = chatMessage.roomId
        self.content = chatMessage.content
        self.senderId = chatMessage.senderId
        self.senderNick = chatMessage.senderNick
        self.senderProfileImage = chatMessage.senderProfileImage ?? ""
        
        if let files = chatMessage.files {
            self.files.append(objectsIn: files)
        }
        
        self.createdAt = chatMessage.createdAt
        self.isRead = chatMessage.isRead
        self.isSent = chatMessage.isSent
        
        if let currentUserId = RealmCurrentUser.getCurrentUserId() {
            self.isMine = (chatMessage.senderId == currentUserId)
        } else {
            self.isMine = false
        }
    }
    
    convenience init(
        id: String,
        roomId: String,
        content: String,
        senderId: String,
        senderNick: String,
        senderProfileImage: String = "",
        files: [String] = [],
        createdAt: Date = Date(),
        isRead: Bool = false,
        isSent: Bool = true
    ) {
        self.init()
        self.id = id
        self.roomId = roomId
        self.content = content
        self.senderId = senderId
        self.senderNick = senderNick
        self.senderProfileImage = senderProfileImage
        
        if !files.isEmpty {
            self.files.append(objectsIn: files)
        }
        
        self.createdAt = createdAt
        self.isRead = isRead
        self.isSent = isSent
        
        if let currentUserId = RealmCurrentUser.getCurrentUserId() {
            self.isMine = (senderId == currentUserId)
        } else {
            self.isMine = false
        }
    }
}
