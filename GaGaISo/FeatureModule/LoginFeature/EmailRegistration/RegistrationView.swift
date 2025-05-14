//
//  RegistrationView.swift
//  LoginFeatureExperiment
//
//  Created by marty.academy on 5/11/25.
//

import SwiftUI

struct SignUpView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var nickname: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("가가이소의 회원이 됩시다! 👋")
                .jalnanFont(size: .title1)
                .foregroundStyle(.gray75)
            
            Text("아이디와 비밀번호 입력해주세요")
                .jalnanFont(size: .title1)
                .foregroundStyle(.gray90)
                .padding(.bottom, 24)
            
            Group {
                InputField(title: "아이디", text: $email, isSecure: false)
                InputField(title: "비밀번호", text: $password, isSecure: true)
                InputField(title: "비밀번호 확인", text: $confirmPassword, isSecure: true)
                InputField(title: "닉네임", text: $nickname, isSecure: false)
            }
            .padding(.horizontal, 32)
            
            Button(action: {
                // 회원가입 처리 로직
            }) {
                Text("회원가입")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blackSprout)
                    .foregroundStyle(.gray0)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 32)
            .padding(.top, 16)
            
            Spacer()
        }
        .background(Color(red: 235/255, green: 240/255, blue: 230/255))
        .edgesIgnoringSafeArea(.all)
    }
}

// MARK: - Custom Input Field
struct InputField: View {
    let title: String
    @Binding var text: String
    var isSecure: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .pretendardFont(size: .body1, weight: .bold)
                .foregroundStyle(.gray75)
            
            Group {
                if isSecure {
                    SecureField("", text: $text)
                } else {
                    TextField("", text: $text)
                }
            }
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
    }
}

#Preview {
    SignUpView()
}
