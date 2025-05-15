//
//  AppleSignView.swift
//  LoginFeatureExperiment
//
//  Created by marty.academy on 5/11/25.
//
import SwiftUI
import AuthenticationServices

struct AppleSignInView: View {
    
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
                Task {
                    await viewModel.handleSuccessfulLogin(with: authorization)
                }
            case .failure(let error):
                viewModel.handleLoginError(with: error)
            }
        }
        .frame(height: 50)
    }
}
