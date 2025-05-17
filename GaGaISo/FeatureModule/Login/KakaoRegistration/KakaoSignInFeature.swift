//
//  KakaoSignViewModel.swift
//  LoginFeatureExperiment
//
//  Created by marty.academy on 5/11/25.
//

import Foundation
import KakaoSDKUser
import ComposableArchitecture

@Reducer
struct KakaoSignInFeature {
    struct State: Equatable {
        var isLoading = false
        var errorMessage: String?
    }
    
    @CasePathable
    enum Action: Equatable {
        case kakaoLoginTapped
        case kakaoLoginSuccess(String)
        case kakaoLoginFailure(String)
        case loginProcessed
        case loginFailed(String)
    }
    
    @Dependency(\.authManager) var authManager
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .kakaoLoginTapped:
                state.isLoading = true
                state.errorMessage = nil
                
                return .run { send in
                    do {
                        if UserApi.isKakaoTalkLoginAvailable() {
                            let accessToken: String = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
                                UserApi.shared.loginWithKakaoTalk { oauthToken, error in
                                    if let error = error {
                                        continuation.resume(throwing: error)
                                    } else if let accessToken = oauthToken?.accessToken {
                                        continuation.resume(returning: accessToken)
                                    } else {
                                        continuation.resume(throwing: NSError(domain: "KakaoLogin", code: -1, userInfo: [NSLocalizedDescriptionKey: "토큰 정보가 없습니다."]))
                                    }
                                }
                            }
                            
                            await send(.kakaoLoginSuccess(accessToken))
                        } else {
                            let accessToken: String = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
                                UserApi.shared.loginWithKakaoAccount { oauthToken, error in
                                    if let error = error {
                                        continuation.resume(throwing: error)
                                    } else if let accessToken = oauthToken?.accessToken {
                                        continuation.resume(returning: accessToken)
                                    } else {
                                        continuation.resume(throwing: NSError(domain: "KakaoLogin", code: -1, userInfo: [NSLocalizedDescriptionKey: "토큰 정보가 없습니다."]))
                                    }
                                }
                            }
                            
                            await send(.kakaoLoginSuccess(accessToken))
                        }
                    } catch {
                        await send(.kakaoLoginFailure(error.localizedDescription))
                    }
                }
                
            case let .kakaoLoginSuccess(accessToken):
                return .run { send in
                    do {
                        try await authManager.loginWithKakao(oauthToken: accessToken)
                        await send(.loginProcessed)
                    } catch {
                        await send(.loginFailed(error.localizedDescription))
                    }
                }
                
            case let .kakaoLoginFailure(errorMessage):
                state.isLoading = false
                state.errorMessage = errorMessage
                return .none
                
            case .loginProcessed:
                state.isLoading = false
                return .none
                
            case let .loginFailed(message):
                state.isLoading = false
                state.errorMessage = message
                return .none
            }
        }
    }
}
