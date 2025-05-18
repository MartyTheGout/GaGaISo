//
//  KakaoSignView.swift
//  LoginFeatureExperiment
//
//  Created by marty.academy on 5/11/25.
//

import SwiftUI
import ComposableArchitecture
import Toasts

struct KakaoSignInView: View {
    let store: StoreOf<KakaoSignInFeature>
    
    @Environment(\.presentToast) private var presentToast
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Button {
                viewStore.send(.kakaoLoginTapped)
            } label: {
                Image("kakao_login_button")
                    .resizable()
                    .overlay {
                        if viewStore.isLoading {
                            Color.black.opacity(0.2)
                            ProgressView()
                                .tint(.black)
                        }
                    }
            }
            .disabled(viewStore.isLoading)
            .frame(height: 55)
            .onChange(of: viewStore.errorMessage) { _, newErrorMessage in
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
}
