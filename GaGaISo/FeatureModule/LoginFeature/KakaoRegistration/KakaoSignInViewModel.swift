//
//  KakaoSignViewModel.swift
//  LoginFeatureExperiment
//
//  Created by marty.academy on 5/11/25.
//

import Foundation
import KakaoSDKUser

final class KakaoSignInViewModel: ObservableObject {
    let authManager : AuthenticationManager
    
    init(authManager: AuthenticationManager) {
        self.authManager = authManager
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
                    print("❌ Kakao 계정 로그인 실패: \(error)")
                } else if let accessToken = oauthToken?.accessToken {
                    Task {
                        await self.requestLoginWithKakaoOauth(oauthToken: accessToken)
                    }
                }
            }
        }
    }
    
    func requestLoginWithKakaoOauth(oauthToken: String) async {
        let nick = NicknameGenerator.generate()
        
        await authManager.loginWithKakao(oauthToken: oauthToken) { success in
            if success {
                print("✅ Kakao 로그인 성공")
            } else {
                print("❌ Kakao 로그인 실패 (서버 응답)")
            }
        }
        
        let deviceToken = UserDefaults.standard.string(forKey: "deviceToken") ?? ""
        await authManager.loginWithKakao(oauthToken: oauthToken, completion: {_ in 
            print("")
        })
    }
}
