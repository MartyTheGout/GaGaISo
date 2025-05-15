//
//  LoginView.swift
//  LoginFeatureExperiment
//
//  Created by marty.academy on 5/11/25.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.diContainer) var diContainer
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isShowingSignUp = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            
            Text("이제는 배민말고")
                .jalnanFont(size: .caption1)
                .foregroundStyle(.gray75)
                .padding(.leading, 32)
                
            Text("가가이소에서 가가이소~ 😀")
                .jalnanFont(size: .title1)
                .foregroundStyle(.gray90)
                .padding(.leading, 32)
            
            HStack {
                Spacer()
                Image("donut")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                Spacer()
            }
            .padding(.vertical, 24)
            
            
            VStack(alignment: .leading, spacing: 12) {
                Text("이메일")
                    .pretendardFont(size: .body1, weight: .bold)
                    .foregroundStyle(.gray75)
                
                TextField("", text: $email)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )
                
                Text("비밀번호")
                    .pretendardFont(size: .body1, weight: .bold)
                    .foregroundStyle(.gray75)
                
                SecureField("", text: $password)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )
            }
            .padding(.horizontal,24)
            .padding(.bottom, 24)
            
            Button(action: {
                // 로그인 동작 처리
            }) {
                Text("로그인")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blackSprout)
                    .foregroundStyle(.gray0)
                    .cornerRadius(10)
                    
            }
            .padding(.horizontal, 24)
            
            HStack(spacing: 15) {
                Spacer()
                Text("아직 회원이 아니신가요? ")
                    .pretendardFont(size: .body1)
                    .foregroundStyle(.gray75)
                
                Button(action: {
                    isShowingSignUp = true
                }) {
                    Text("회원가입")
                        .underline()
                        .pretendardFont(size: .body1)
                }
                .buttonStyle(.plain)
                
                Spacer()
            }
            .font(.subheadline)
            .padding(.vertical, 24)
            
            HStack {
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray75)
                
                Text("또는")
                    .pretendardFont(size: .body1)
                    .foregroundColor(.gray75)
                    .padding(.horizontal, 8)
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray75)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            
            AppleSignInView(viewModel: diContainer.getAppleSignViewModel())
                .padding(.horizontal, 24)
            KakaoSignInView(viewModel: diContainer.getKaKaoSignViewModel())
                .padding(.top, 16)
                .padding(.horizontal, 24)
            
            Spacer()
        }
        .padding(.top, 20)
        .background(.brightSprout)
        .edgesIgnoringSafeArea(.all)
        .navigationDestination(isPresented: $isShowingSignUp) {
            SignUpView(usecase: diContainer.getRegistrationUsecase())
                .navigationTitle("회원가입")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    NavigationStack {
        LoginView()
    }
}
