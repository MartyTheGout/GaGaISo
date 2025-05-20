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
    static let liveValue: AuthManagerProtocol = {
        @Dependency(\.authStore) var authStore
        @Dependency(\.networkClient) var networkClient
        return AuthenticationManager(authStore: authStore, networkClient: networkClient)
    }()
    
    static var testValue: AuthManagerProtocol {
        return MockAuthManager()
    }
}

struct NotificationManagerKey: DependencyKey {
    static let liveValue = NotificationManager()
}

struct LocationManagerKey: DependencyKey {
    static let liveValue = LocationManager()
}

enum KakaoUserApiKey: DependencyKey {
    static let liveValue: KakaoUserApiProtocol = KakaoUserApi()
    
    static let testValue: KakaoUserApiProtocol = MockKakaoUserApi()
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
    
    var authManager: AuthManagerProtocol {
        get { self[AuthManagerKey.self] }
        set { self[AuthManagerKey.self] = newValue }
    }
    
    var notificationManager: NotificationManager {
        get { self[NotificationManagerKey.self] }
        set { self[NotificationManagerKey.self] = newValue }
    }
    
    var kakaoUserApi: KakaoUserApiProtocol {
        get { self[KakaoUserApiKey.self] }
        set { self[KakaoUserApiKey.self] = newValue }
    }
    
    var locationManager: LocationManager {
        get { self[LocationManagerKey.self] }
        set { self[LocationManagerKey.self] = newValue }
    }
}

