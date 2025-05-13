//
//  LoginView.swift
//  LoginFeatureExperiment
//
//  Created by marty.academy on 5/11/25.
//

import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isShowingSignUp = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Text("로그인")
                .font(.title)
                .fontWeight(.bold)
            
            Image("donut")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("아이디")
                    .font(.headline)
                
                TextField("", text: $email)
                    .padding()
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )
                
                Text("비밀번호")
                    .font(.headline)
                
                SecureField("", text: $password)
                    .padding()
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )
            }
            .padding(.horizontal, 32)
            
            Button(action: {
                // 로그인 동작 처리
            }) {
                Text("로그인")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 2)
            }
            .padding(.horizontal, 16)
            
            HStack(spacing: 30) {
                Button("회원가입") {
                    isShowingSignUp = true
                }
            }
            .font(.subheadline)
            .padding(.top, 8)
            
            AppleSignInView()
            KakaoSignInView()
            
            Spacer()
        }
        .padding(.top, 20)
        .background(Color(red: 235/255, green: 240/255, blue: 230/255))
        .edgesIgnoringSafeArea(.all)
        .navigationDestination(isPresented: $isShowingSignUp) {
            SignUpView()
                .navigationTitle("회원가입")
                .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            if let deviceTokenValue = UserDefaults.standard.value(forKey: "deviceToken") as? String {
                print("deviceToken Confirmed: \(deviceTokenValue)")
            }
        }
    }
}

#Preview {
    NavigationStack {
        LoginView()
    }
}
