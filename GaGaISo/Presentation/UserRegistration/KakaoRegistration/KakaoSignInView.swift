//
//  KakaoSignView.swift
//  LoginFeatureExperiment
//
//  Created by marty.academy on 5/11/25.
//

import SwiftUI

struct KakaoSignInView: View {
    @StateObject private var viewModel = KakaoSignInViewModel()
    // Working Code: resizable() 이 없으면 View가 아주 개똥-이 된다.
    var body: some View {
        Button {
            viewModel.kakaoLogin()
        } label: {
            Image("kakao_login_button")
                .resizable()
        }
        .frame(height: 55)
        .padding()
    }
}
