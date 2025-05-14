//
//  KakaoSignViewModel.swift
//  LoginFeatureExperiment
//
//  Created by marty.academy on 5/11/25.
//

import Foundation
import KakaoSDKUser

final class KakaoSignInViewModel: ObservableObject {
    let authStore : AuthStore
    
    init(authStore: AuthStore) {
        self.authStore = authStore
    }

    func kakaoLogin() {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { oauthToken, error in
                if let error = error {
                    print(error)
                } else {
                    if let accessToken = oauthToken?.accessToken {
                        Task {
                            await self.requestLoginWithKakaoOauth(oauthToken: accessToken)
                        }
                    } else {
                        print("카카오톡 로그인 success")
                    }
                }
             }
         } else {
            UserApi.shared.loginWithKakaoAccount { oauthToken, error in
                if let error = error {
                    print(error)
                } else {
                    print("카카오계정 로그인 success")

                   _ = oauthToken
                }
            }
        }
    }
    
    func requestLoginWithKakaoOauth(oauthToken: String) async {
        let deviceToken = UserDefaults.standard.string(forKey: "deviceToken") ?? ""
        let response = await NetworkHandler.request(TestRouter.v1KakaoLogin(oauthToken: oauthToken, deviceToken: deviceToken), type: LoginResponse.self)
        dump(response)
    }
}
