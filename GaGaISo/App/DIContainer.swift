//
//  DIContainer.swift
//  GaGaISo
//
//  Created by marty.academy on 5/13/25.
//

import Foundation

final class DIContainer {
    let authStore: AuthStore
    let authManager: AuthenticationManager

    init() {
        self.authStore = AuthStore()
        self.authManager = AuthenticationManager(authStore: authStore)
    }
    
    @MainActor
    func getAppleSignViewModel() -> AppleSignInViewModel {
        return AppleSignInViewModel(authManager: authManager)
    }
    
    @MainActor
    func getKaKaoSignViewModel() -> KakaoSignInViewModel {
        return KakaoSignInViewModel(authManager: authManager)
    }
}
