//
//  Realm.swift
//  GaGaISo
//
//  Created by marty.academy on 6/3/25.
//

import Foundation
import RealmSwift
/**
 For having per-user data-safe environment,
 Realm needs to be separated by user-unit. and switch every time when different user logs in
 */
class UserRealmManager {
    private var currentUserId: String?
    private var currentConfiguration: Realm.Configuration?
    
    // For thread-safe way of using realm, save Realm.Configuration, but create Realm for each time
    func setCurrentUser(_ userId: String?) {
        guard let userId else {
            currentUserId = nil
            currentConfiguration = nil
            return
        }
        
        currentUserId = userId
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let userRealmPath = documentsPath.appendingPathComponent("user_\(userId).realm")
        
        currentConfiguration = Realm.Configuration(
            fileURL: userRealmPath,
            schemaVersion: 1
        )
    }
    
    func getCurrentUserId() -> String? {
        return currentUserId
    }
    
    func createRealm() -> Realm {
        guard let config = currentConfiguration else {
            fatalError("[Realm Error] setCurrentUser() needs to be called firstly")
        }
        
        return try! Realm(configuration: config)
    }
    
    func clearUserData() {
        currentUserId = nil
        currentConfiguration = nil
    }
    
    
    func deleteUserData(for userId: String) {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let userRealmPath = documentsPath.appendingPathComponent("user_\(userId).realm")
        
        try? FileManager.default.removeItem(at: userRealmPath)
        
        try? FileManager.default.removeItem(at: userRealmPath.appendingPathExtension("lock"))
        try? FileManager.default.removeItem(at: userRealmPath.appendingPathExtension("note"))
        try? FileManager.default.removeItem(at: userRealmPath.appendingPathExtension("management"))
    }
}
