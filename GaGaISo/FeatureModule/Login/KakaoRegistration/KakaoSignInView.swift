//
//  KakaoSignView.swift
//  LoginFeatureExperiment
//
//  Created by marty.academy on 5/11/25.
//

import SwiftUI
import ComposableArchitecture

struct KakaoSignInView: View {
    let store: StoreOf<KakaoSignInFeature>
    
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
