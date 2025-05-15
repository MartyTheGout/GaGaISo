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
    let networkClient: RawNetworkClient

    init() {
        self.authStore = AuthStore()
        self.networkClient = RawNetworkClient()
        self.authManager = AuthenticationManager(authStore: authStore, networkClient: networkClient)
    }
    
    @MainActor
    func getAppleSignViewModel() -> AppleSignInViewModel {
        return AppleSignInViewModel(authManager: authManager)
    }
    
    @MainActor
    func getKaKaoSignViewModel() -> KakaoSignInViewModel {
        return KakaoSignInViewModel(authManager: authManager )
    }
    
    @MainActor
    func getRegistrationUsecase() -> RegistrationUsecase {
        return RegistrationUsecase(networkClient: networkClient)
    }
}
