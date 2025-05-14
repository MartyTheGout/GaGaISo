//
//  RegistrationView.swift
//  LoginFeatureExperiment
//
//  Created by marty.academy on 5/11/25.
//

import SwiftUI

struct SignUpView: View {
    
    enum SignUpField: Hashable {
        case email, password, confirmPassword, nickname
    }
    
    @FocusState private var focusedField: SignUpField?
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var nickname: String = ""
    
    @StateObject private var useCase = RegistrationUsecase()
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("가가이소의 회원이 됩시다! 👋")
                .jalnanFont(size: .title1)
                .foregroundStyle(.gray75)
            
            Text("이메일와 비밀번호 입력해주세요")
                .jalnanFont(size: .title1)
                .foregroundStyle(.gray90)
                .padding(.bottom, 24)
            
            Group {
                InputField(title: "이메일", text: $email, errorMessage: "유효한 이메일 형식이 아닙니다.",  isSecure: false, verificationHandler: { value in
                    return useCase.isValidEmail(value)
                }, focusedField: $focusedField, currentField: .email)
                
                InputField(title: "비밀번호", text: $password, errorMessage: "최소 8자 이상, 영문, 숫자, 특수문자(@$!%*#?&)를 포함해야합니다.", isSecure: true, verificationHandler: { value in
                    return useCase.isValidPassword(value)
                }, focusedField: $focusedField, currentField: .password)
                
                InputField(title: "비밀번호 확인", text: $confirmPassword, errorMessage: "비밀번호가 일치하지 않습니다.",isSecure: true, verificationHandler: { value in
                    return value == password
                }, focusedField: $focusedField, currentField: .confirmPassword)
                
                InputField(title: "닉네임", text: $nickname, errorMessage: "., ,, ?, *, -, @ 는 사용할 수 없습니다.", isSecure: false, verificationHandler: { value in
                    return useCase.isValidNickname(value)
                }, focusedField: $focusedField, currentField: .nickname)
            }
            .padding(.horizontal, 32)
            
            Button(action: {
                Task {
                    await useCase.register(email: email, password: password, nickname: nickname, completion: {})
                }
                
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

struct InputField: View {
    let title: String
    @Binding var text: String
    let errorMessage: String
    var isSecure: Bool = false
    let verificationHandler: (String) -> Bool
    
    @FocusState.Binding var focusedField: SignUpView.SignUpField?
    let currentField: SignUpView.SignUpField
    
    @State private var isTouched: Bool = false
    @State private var isValid: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .pretendardFont(size: .body1, weight: .bold)
                    .foregroundStyle(.gray75)
                
                Spacer()
                
                if !isValid && isTouched {
                    Text(errorMessage)
                        .pretendardFont(size: .caption2, weight: .bold)
                        .foregroundStyle(.red)
                }
            }
            
            Group {
                if isSecure {
                    SecureField("", text: $text).focused($focusedField, equals: currentField)
                } else {
                    TextField("", text: $text).focused($focusedField, equals: currentField)
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
            .onChange(of: focusedField) { newValue in
                if newValue == currentField {
                    isTouched = true
                } else {
                    if isTouched {
                        isValid = verificationHandler(text)
                    }
                }
            }
        }
    }
}

#Preview {
    SignUpView()
}
