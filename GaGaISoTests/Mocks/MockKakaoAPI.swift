//
//  MockKakaoAPI.swift
//  GaGaISo
//
//  Created by marty.academy on 5/19/25.
//

import Foundation

struct MockKakaoUserApi: KakaoUserApiProtocol {
    var isKakaoTalkLoginAvailableResult: Bool = true
    var loginWithKakaoTalkResult: (OAuthToken?, Error?) = (OAuthToken(accessToken: "mock-kakao-token"), nil)
    var loginWithKakaoAccountResult: (OAuthToken?, Error?) = (OAuthToken(accessToken: "mock-kakao-account-token"), nil)
    
    func isKakaoTalkLoginAvailable() -> Bool {
        return isKakaoTalkLoginAvailableResult
    }
    
    func loginWithKakaoTalk(completion: @escaping (OAuthToken?, Error?) -> Void) {
        completion(loginWithKakaoTalkResult.0, loginWithKakaoTalkResult.1)
    }
    
    func loginWithKakaoAccount(completion: @escaping (OAuthToken?, Error?) -> Void) {
        completion(loginWithKakaoAccountResult.0, loginWithKakaoAccountResult.1)
    }
}
