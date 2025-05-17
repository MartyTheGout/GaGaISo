//
//  Dependencies.swift
//  GaGaISo
//
//  Created by marty.academy on 5/17/25.
//

import ComposableArchitecture

struct AuthStoreKey: DependencyKey {
    static let liveValue = AuthStore()
}

struct NetworkClientKey: DependencyKey {
    static let liveValue = RawNetworkClient()
}

struct AuthManagerKey: DependencyKey {
    static let liveValue: AuthenticationManager = {
        @Dependency(\.authStore) var authStore
        @Dependency(\.networkClient) var networkClient
        return AuthenticationManager(authStore: authStore, networkClient: networkClient)
    }()
}

struct NotificationManagerKey: DependencyKey {
    static let liveValue = NotificationManager()
}

extension DependencyValues {
    var authStore: AuthStore {
        get { self[AuthStoreKey.self] }
        set { self[AuthStoreKey.self] = newValue }
    }
    
    var networkClient: RawNetworkClient {
        get { self[NetworkClientKey.self] }
        set { self[NetworkClientKey.self] = newValue }
    }
    
    var authManager: AuthenticationManager {
        get { self[AuthManagerKey.self] }
        set { self[AuthManagerKey.self] = newValue }
    }
    
    var notificationManager: NotificationManager {
        get { self[NotificationManagerKey.self] }
        set { self[NotificationManagerKey.self] = newValue }
    }
}
