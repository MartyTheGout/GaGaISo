//
//  LoginFeature.swift
//  GaGaISo
//
//  Created by marty.academy on 5/17/25.
//

import ComposableArchitecture
import AuthenticationServices

@Reducer
struct LoginFeature {
    struct State: Equatable {
        var email: String = ""
        var password: String = ""
        var isShowingSignUp = false
        
        var isLoading = false
        var errorMessage: String?
        
        var appleSignIn = AppleSignInFeature.State()
        var kakaoSignIn = KakaoSignInFeature.State()
        var signUp = SignUpFeature.State()
    }
    
    @CasePathable
    enum Action: Equatable {
        case emailChanged(String)
        case passwordChanged(String)
        case loginButtonTapped
        case signUpButtonTapped
        case signUpDismissed
        
        case appleSignIn(AppleSignInFeature.Action)
        case kakaoSignIn(KakaoSignInFeature.Action)
        case signUp(SignUpFeature.Action)
        
        case loginProcessed
        case loginFailed(String)
    }
    
    @Dependency(\.authManager) var authManager
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .emailChanged(email):
                state.email = email
                return .none
                
            case let .passwordChanged(password):
                state.password = password
                return .none
                
            case .loginButtonTapped:
                let email = state.email
                let password = state.password
                
                return .run { send in
                    print(".loginButtonTapped is working")
                    let serverLoginResponse = await authManager.loginWithEmail(email: email, password: password)
                    switch serverLoginResponse {
                    case.success :
                        await send(.loginProcessed)
                    case .failure(let error) :
                        await send(.loginFailed(error.localizedDescription))
                    }
                }
                
            case .signUpButtonTapped:
                state.isShowingSignUp = true
                return .none
                
            case .signUpDismissed:
                state.isShowingSignUp = false
                return .none
                
            case .appleSignIn:
                return .none
                
            case .kakaoSignIn:
                return .none
                
            case .signUp :
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
        
        Scope(state: \.appleSignIn, action: \.appleSignIn) {
            AppleSignInFeature()
        }
        
        Scope(state: \.kakaoSignIn, action: \.kakaoSignIn) {
            KakaoSignInFeature()
        }
        
        Scope(state: \.signUp, action: \.signUp) {
            SignUpFeature()
        }
    }
}
