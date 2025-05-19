//
//  KakaoAPIProtocol.swift
//  GaGaISo
//
//  Created by marty.academy on 5/19/25.
//

import Foundation

struct OAuthToken {
    let accessToken: String
}

protocol KakaoUserApiProtocol {
    func isKakaoTalkLoginAvailable() -> Bool
    func loginWithKakaoTalk(completion: @escaping (OAuthToken?, Error?) -> Void)
    func loginWithKakaoAccount(completion: @escaping (OAuthToken?, Error?) -> Void)
}

