//
//  EntryFeature.swift
//  GaGaISo
//
//  Created by marty.academy on 5/17/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct AppFeature {
    struct State: Equatable {
        var isBootstrapping = true
        
        var login = LoginFeature.State()
        var content = ContentFeature.State()
    }
    
    @CasePathable
    enum Action: Equatable {
        case onAppear
        case bootstrapCompleted
        case login(LoginFeature.Action)
        case content(ContentFeature.Action)
    }
    
    @Dependency(\.authManager) var authManager
    @Dependency(\.authStore) var authStore
    @Dependency(\.notificationManager) var notificationManager
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isBootstrapping = true
                
                if authStore.deviceToken == nil {
                    // NotificationManager is already injected with initialized state.
                } else {
                    print("Device Token already exists: App start without device token registration")
                }
                
                return .run { send in
                    await authManager.bootstrap()
                    await send(.bootstrapCompleted)
                }
                
            case .bootstrapCompleted:
                state.isBootstrapping = false
                return .none
                
            case .login:
                return .none
                
            case .content:
                return .none
            }
        }
        
        Scope(state: \.login, action: \.login) {
            LoginFeature()
        }
        
        Scope(state: \.content, action: \.content) {
            ContentFeature()
        }
    }
}
