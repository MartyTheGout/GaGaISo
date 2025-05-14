//
//  AppleSignViewModel.swift
//  LoginFeatureExperiment
//
//  Created by marty.academy on 5/11/25.
//

import Foundation
import AuthenticationServices

struct LoginResponse: Decodable {
    var user_id : String
    var email : String
    var nick : String
    var profileImage: String?
    var accessToken: String
    var refreshToken: String
}


final class AppleSignInViewModel: ObservableObject {
    
    var authStore: AuthStore
    
    init(authStore: AuthStore) {
        self.authStore = authStore
    }
    
    func handleSuccessfulLogin(with authorization: ASAuthorization) async {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            print("❌ 인증 정보가 올바르지 않습니다.")
            return
        }

        print("============== 성공 ==============")
        print("user: \(credential.user)")
        
        if let identityToken = credential.identityToken,
           let tokenString = String(data: identityToken, encoding: .utf8) {
            let deviceToken = authStore.deviceToken
            
            let nick = NicknameGenerator.generate()
            
            print("identityToken (JWT): \(tokenString)")
            
            let response = await NetworkHandler.request(
                TestRouter.v1AppleLogin(
                    idToken: tokenString,
                    deviceToken: deviceToken ?? "",
                    nick: nick
                ), type: LoginResponse.self
            )
            
            dump(response)
        } else {
            print("❌ identityToken 없음")
        }

        if credential.authorizedScopes.contains(.fullName) {
            print("fullName: \(credential.fullName?.givenName ?? "없음")")
        }

        if credential.authorizedScopes.contains(.email) {
            print("email: \(credential.email ?? "없음")")
        }

        print("==================================")
    }
    
    func handleLoginError(with error: Error) {
        print("❌ 인증 실패: \(error.localizedDescription)")
    }
}

