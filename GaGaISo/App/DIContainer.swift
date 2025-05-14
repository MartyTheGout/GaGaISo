//
//  DIContainer.swift
//  GaGaISo
//
//  Created by marty.academy on 5/13/25.
//

import Foundation

final class DIContainer {
    let authStore: AuthStore

    init() {
        self.authStore = AuthStore()
    }
    
    @MainActor
    func getAppleSignViewModel() -> AppleSignInViewModel {
        return AppleSignInViewModel(authStore: authStore)
    }
    
    @MainActor
    func getKaKaoSignViewModel() -> KakaoSignInViewModel {
        return KakaoSignInViewModel(authStore: authStore)
    }
}
