//
//  CurrentUser.swift
//  GaGaISo
//
//  Created by marty.academy on 6/4/25.
//

import RealmSwift
import Foundation

class RealmCurrentUser: Object, ObjectKeyIdentifiable {
    @Persisted var userId: String = ""
    @Persisted var nick: String = ""
    @Persisted var loginAt: Date = Date()
    
    override static func primaryKey() -> String? { "userId" }
    
    convenience init(
           userId: String,
           nick: String,
           loginAt: Date = Date()
       ) {
           self.init()
           self.userId = userId
           self.nick = nick
           self.loginAt = loginAt
       }
    
    static func getCurrentUser() -> RealmCurrentUser? {
        let realm = try! Realm()
        return realm.objects(RealmCurrentUser.self).first
    }
    
    static func getCurrentUserId() -> String? {
        return getCurrentUser()?.userId
    }
    
    static func setCurrentUser(userId: String, nick: String) {
        let realm = try! Realm()
        
        let currentUserId = getCurrentUserId()
        if userId == currentUserId { return }
        
        try! realm.write {
            if let currentUserId, currentUserId != userId {
                print("[User Setting] New Login detected")
                realm.delete(realm.objects(RealmCurrentUser.self))
                realm.delete(realm.objects(RealmChatRoom.self))
                realm.delete(realm.objects(RealmChatMessage.self))
                realm.delete(realm.objects(RealmParticipant.self))
            }
            
            let currentUser = RealmCurrentUser(userId: userId, nick: nick)
            realm.add(currentUser)
            
            print("[User Setting] New User set: \(userId)")
        }
    }
    
    static func clearCurrentUser() {
        let realm = try! Realm()
        
        try! realm.write {
            realm.delete(realm.objects(RealmCurrentUser.self))
            
            realm.delete(realm.objects(RealmChatRoom.self))
            realm.delete(realm.objects(RealmChatMessage.self))
            realm.delete(realm.objects(RealmParticipant.self))
            
            print("[User Setting] Current User Data Cleared")
        }
    }
}
