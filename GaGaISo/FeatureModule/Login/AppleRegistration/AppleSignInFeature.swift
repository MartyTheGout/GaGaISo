//
//  AppleSignInFeature.swift
//  GaGaISo
//
//  Created by marty.academy on 5/16/25.
//
import SwiftUI
import ComposableArchitecture
import AuthenticationServices

@Reducer
struct AppleSignInFeature {
    struct State: Equatable {
        var isLoading = false
        var errorMessage: String?
    }
    
    @CasePathable
    enum Action: Equatable {
        case signInWithAppleTapped
        case authorizationSuccess(ASAuthorization)
        case authorizationFailure(String)
        case loginProcessed
        case loginFailed(String)
    }
    
    @Dependency(\.authManager) var authManager
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .signInWithAppleTapped:
                state.isLoading = true
                state.errorMessage = nil
                return .none
                
            case let .authorizationSuccess(authorization):
                guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                      let identityToken = credential.identityToken,
                      let tokenString = String(data: identityToken, encoding: .utf8) else {
                    state.isLoading = false
                    state.errorMessage = "인증 정보가 올바르지 않습니다."
                    return .send(.loginFailed("인증 정보가 올바르지 않습니다."))
                }
                
                let nick = NicknameGenerator.generate()
                
                return .run { send in
                    let serverLoginResponse = await authManager.loginWithApple(idToken: tokenString, nick: nick)
                    switch serverLoginResponse {
                    case .success:
                        await send(.loginProcessed)
                    case .failure(let error):
                        await send(.loginFailed(error.localizedDescription))
                    }
                    await send(.loginProcessed)
                }
                
            case .authorizationFailure(let errorMessageFromApple):
                return .run { send in
                    await send(.loginFailed(errorMessageFromApple))
                }
                
            case .loginProcessed:
                state.isLoading = false
                return .none
                
            case .loginFailed(let message):
                state.isLoading = false
                state.errorMessage = message
                return .none
            }
        }
    }
}
