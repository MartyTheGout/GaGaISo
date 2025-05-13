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
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 2)
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
                .font(.headline)

            Group {
                if isSecure {
                    SecureField("", text: $text)
                } else {
                    TextField("", text: $text)
                }
            }
            .padding()
            .background(Color.white)
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
