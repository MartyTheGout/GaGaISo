//
//  AppleSignView.swift
//  LoginFeatureExperiment
//
//  Created by marty.academy on 5/11/25.
//

import SwiftUI
import AuthenticationServices
import ComposableArchitecture

struct AppleSignInView: View {
    let store: StoreOf<AppleSignInFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                switch result {
                case .success(let authorization):
                    viewStore.send(.authorizationSuccess(authorization))
                case .failure(let error):
                    viewStore.send(.authorizationFailure(error.localizedDescription))
                }
            }
            .frame(height: 50)
            .disabled(viewStore.isLoading)
            .overlay {
                if viewStore.isLoading {
                    ProgressView()
                }
            }
            .alert(
                "로그인 오류",
                isPresented: .init(
                    get: { viewStore.errorMessage != nil },
                    set: { if !$0 { viewStore.send(.loginFailed("")) } }
                ),
                actions: {
                    Button("확인") {}
                },
                message: {
                    if let errorMessage = viewStore.errorMessage {
                        Text(errorMessage)
                    }
                }
            )
        }
    }
}
