//
//  TokenStore.swift
//  LoginFeatureExperiment
//
//  Created by marty.academy on 5/12/25.
//

import Foundation
import Security

final class AuthStore: AbstractAuthStore {
    
    private let accessTokenKey = "accessToken"
    private let refreshTokenKey = "refreshToken"
    private let deviceTokenKey = "deviceToken"
    private let loginMethodKey = "loginMethod"
    
    var accessToken: String? {
        get { load(forKey: accessTokenKey) }
        set {
            if let value = newValue {
                save(value, forKey: accessTokenKey)
            } else {
                delete(forKey: accessTokenKey)
            }
        }
    }

    var refreshToken: String? {
        get { load(forKey: refreshTokenKey) }
        set {
            if let value = newValue {
                save(value, forKey: refreshTokenKey)
            } else {
                delete(forKey: refreshTokenKey)
            }
        }
    }
    
    var loginMethod: String? {
        get { load(forKey: loginMethodKey) }
        set {
            if let value = newValue {
                save(value, forKey: loginMethodKey)
            } else {
                delete(forKey: loginMethodKey)
            }
        }
    }
    
    var deviceToken: String? {
        get { load(forKey: deviceTokenKey) }
        set {
            if let value = newValue {
                save(value, forKey: deviceTokenKey)
            } else {
                delete(forKey: deviceTokenKey)
            }
        }
    }
               
    func clear() {
        delete(forKey: accessTokenKey)
        delete(forKey: refreshTokenKey)
        delete(forKey: deviceTokenKey)
        delete(forKey: loginMethodKey)
    }
    
    // MARK: - Low-level keychain
    private func save(_ value: String, forKey key: String) {
        guard let data = value.data(using: .utf8) else { return }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    private func load(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        if SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
           let data = result as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }

    private func delete(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
