//
//  AppleSignView.swift
//  LoginFeatureExperiment
//
//  Created by marty.academy on 5/11/25.
//

import SwiftUI
import AuthenticationServices
import Toasts

struct AppleSignInView: View {
    @Environment(\.presentToast) private var presentToast
    
    @StateObject private var viewModel: AppleSignInViewModel
    
    init(viewModel: AppleSignInViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        SignInWithAppleButton(.signIn) { request in
            request.requestedScopes = [.fullName, .email]
        } onCompletion: { result in
            switch result {
            case .success(let authorization):
                viewModel.handleAuthorization(authorization)
            case .failure(let error):
                viewModel.handleAuthorizationFailure(error)
            }
        }
        .frame(height: 50)
        .disabled(viewModel.isLoading)
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .onChange(of: viewModel.errorMessage) { _, newErrorMessage in
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
