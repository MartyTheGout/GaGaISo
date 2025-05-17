//
//  AppleSignViewModel.swift
//  LoginFeatureExperiment
//
//  Created by marty.academy on 5/11/25.
//

import Foundation
import AuthenticationServices

final class AppleSignInViewModel: ObservableObject {
    private let authManager: AuthenticationManager

    init(authManager: AuthenticationManager) {
        self.authManager = authManager
    }

    func handleSuccessfulLogin(with authorization: ASAuthorization) async {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            print("❌ 인증 정보가 올바르지 않습니다.")
            return
        }

        guard let identityToken = credential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8) else {
            print("❌ identityToken 없음")
            return
        }

        let nick = NicknameGenerator.generate()

        await authManager.loginWithApple(idToken: tokenString, nick: nick) 
    }

    func handleLoginError(with error: Error) {
        print("❌ 인증 실패: \(error.localizedDescription)")
    }
}
