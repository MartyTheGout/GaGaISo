//
//  AppleSignInViewModel.swift
//  GaGaISo
//
//  Created by marty.academy on 5/21/25.
//

import Foundation
import Combine
import AuthenticationServices

class AppleSignInViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let authManager: AuthManagerProtocol
    
    init(authManager: AuthManagerProtocol) {
        self.authManager = authManager
    }
    
    func handleAuthorization(_ authorization: ASAuthorization) {
        isLoading = true
        
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let identityToken = credential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8) else {
            errorMessage = "인증 정보가 올바르지 않습니다."
            isLoading = false
            return
        }
        
        let nick = NicknameGenerator.generate()
        
        Task {
            let result = await authManager.loginWithApple(idToken: tokenString, nick: nick)
            
            await MainActor.run {
                isLoading = false
                
                switch result {
                case .success:
                    // 로그인 성공 - authManager.isLoggedIn을 통해 처리됨
                    break
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func handleAuthorizationFailure(_ error: Error) {
        isLoading = false
        errorMessage = error.localizedDescription
    }
}
