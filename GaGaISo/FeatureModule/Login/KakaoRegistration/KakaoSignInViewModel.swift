//
//  KakaoSignInViewModel.swift
//  GaGaISo
//
//  Created by marty.academy on 5/21/25.
//

import Foundation
import Combine

class KakaoSignInViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let authManager: AuthManagerProtocol
    private let kakaoUserApi: KakaoUserApiProtocol
    
    init(authManager: AuthManagerProtocol, kakaoUserApi: KakaoUserApiProtocol) {
        self.authManager = authManager
        self.kakaoUserApi = kakaoUserApi
    }
    
    func kakaoLoginTapped() {
        isLoading = true
        
        Task {
            do {
                if kakaoUserApi.isKakaoTalkLoginAvailable() {
                    let accessToken: String = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
                        kakaoUserApi.loginWithKakaoTalk { oauthToken, error in
                            if let error = error {
                                continuation.resume(throwing: error)
                            } else if let accessToken = oauthToken?.accessToken {
                                continuation.resume(returning: accessToken)
                            } else {
                                continuation.resume(throwing: NSError(domain: "KakaoLogin", code: -1, userInfo: [NSLocalizedDescriptionKey: "토큰 정보가 없습니다."]))
                            }
                        }
                    }
                    
                    await handleKakaoToken(accessToken)
                } else {
                    let accessToken: String = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
                        kakaoUserApi.loginWithKakaoAccount { oauthToken, error in
                            if let error = error {
                                continuation.resume(throwing: error)
                            } else if let accessToken = oauthToken?.accessToken {
                                continuation.resume(returning: accessToken)
                            } else {
                                continuation.resume(throwing: NSError(domain: "KakaoLogin", code: -1, userInfo: [NSLocalizedDescriptionKey: "토큰 정보가 없습니다."]))
                            }
                        }
                    }
                    
                    await handleKakaoToken(accessToken)
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func handleKakaoToken(_ accessToken: String) async {
        let result = await authManager.loginWithKakao(oauthToken: accessToken)
        
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
