//
//  AppleSignView.swift
//  LoginFeatureExperiment
//
//  Created by marty.academy on 5/11/25.
//

import SwiftUI
import AuthenticationServices
import ComposableArchitecture
import Toasts

struct AppleSignInView: View {
    @Environment(\.presentToast) private var presentToast
    
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
            .onChange(of: viewStore.errorMessage) { _, newErrorMessage in
                if let errorMessage = newErrorMessage {
                    let toast = ToastValue (
                        icon: Image(systemName: "exclamationmark.triangle"),
                        message: errorMessage,
                        duration: 3.0
                    )
                    presentToast(toast)
                }
                
            }
        }
    }
}
