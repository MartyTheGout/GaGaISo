//
//  KakaoAPI.swift
//  GaGaISo
//
//  Created by marty.academy on 5/19/25.
//

import Foundation
import KakaoSDKUser

struct KakaoUserApi: KakaoUserApiProtocol {
    func isKakaoTalkLoginAvailable() -> Bool {
        return UserApi.isKakaoTalkLoginAvailable()
    }
    
    func loginWithKakaoTalk(completion: @escaping (OAuthToken?, Error?) -> Void) {
        UserApi.shared.loginWithKakaoTalk { oauthToken, error in
            // KakaoSDK의 OAuthToken을 우리의 OAuthToken으로 변환
            let token = oauthToken.map { OAuthToken(accessToken: $0.accessToken) }
            completion(token, error)
        }
    }
    
    func loginWithKakaoAccount(completion: @escaping (OAuthToken?, Error?) -> Void) {
        UserApi.shared.loginWithKakaoAccount { oauthToken, error in
            let token = oauthToken.map { OAuthToken(accessToken: $0.accessToken) }
            completion(token, error)
        }
    }
}
