//
//  KakaoSignView.swift
//  LoginFeatureExperiment
//
//  Created by marty.academy on 5/11/25.
//

import SwiftUI
import Toasts

struct KakaoSignInView: View {
    @Environment(\.presentToast) private var presentToast
    @StateObject private var viewModel: KakaoSignInViewModel
    
    init(viewModel: KakaoSignInViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        Button {
            viewModel.kakaoLoginTapped()
        } label: {
            Image("kakao_login_button")
                .resizable()
                .overlay {
                    if viewModel.isLoading {
                        Color.black.opacity(0.2)
                        ProgressView()
                            .tint(.black)
                    }
                }
        }
        .disabled(viewModel.isLoading)
        .frame(height: 55)
        .onChange(of: viewModel.errorMessage) { _, newErrorMessage in
            if let errorMessage = newErrorMessage {
                let toast = ToastValue(
                    icon: Image(systemName: "exclamationmark.triangle"),
                    message: errorMessage,
                    duration: 3.0
                )
                presentToast(toast)
            }
        }
        
    }
}
