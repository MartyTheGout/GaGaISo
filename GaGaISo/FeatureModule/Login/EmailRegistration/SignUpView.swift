//
//  RegistrationView.swift
//  LoginFeatureExperiment
//
//  Created by marty.academy on 5/11/25.
//
import SwiftUI
import Combine

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: SignUpViewModel
    @FocusState private var focusedField: SignUpField?
    
    init(viewModel: SignUpViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
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
                InputField(
                    title: "이메일",
                    text: viewModel.email,
                    errorMessage: "유효한 이메일 형식이 아닙니다.",
                    isSecure: false,
                    isTouched: viewModel.fieldStates[.email]?.isTouched ?? false,
                    isValid: viewModel.fieldStates[.email]?.isValid ?? true,
                    onTextChanged: { viewModel.updateEmail($0) },
                    onFocusChanged: { isFocused in
                        if isFocused {
                            viewModel.focusChanged(.email)
                            focusedField = .email
                        } else {
                            viewModel.fieldBlurred(.email)
                        }
                    }
                )
                
                InputField(
                    title: "비밀번호",
                    text: viewModel.password,
                    errorMessage: "최소 8자 이상, 영문, 숫자, 특수문자(@$!%*#?&)를 포함해야합니다.",
                    isSecure: true,
                    isTouched: viewModel.fieldStates[.password]?.isTouched ?? false,
                    isValid: viewModel.fieldStates[.password]?.isValid ?? true,
                    onTextChanged: { viewModel.updatePassword($0) },
                    onFocusChanged: { isFocused in
                        if isFocused {
                            viewModel.focusChanged(.password)
                            focusedField = .password
                        } else {
                            viewModel.fieldBlurred(.password)
                        }
                    }
                )
                
                InputField(
                    title: "비밀번호 확인",
                    text: viewModel.confirmPassword,
                    errorMessage: "비밀번호가 일치하지 않습니다.",
                    isSecure: true,
                    isTouched: viewModel.fieldStates[.confirmPassword]?.isTouched ?? false,
                    isValid: viewModel.fieldStates[.confirmPassword]?.isValid ?? true,
                    onTextChanged: { viewModel.updateConfirmPassword($0) },
                    onFocusChanged: { isFocused in
                        if isFocused {
                            viewModel.focusChanged(.confirmPassword)
                            focusedField = .confirmPassword
                        } else {
                            viewModel.fieldBlurred(.confirmPassword)
                        }
                    }
                )
                
                InputField(
                    title: "닉네임",
                    text: viewModel.nickname,
                    errorMessage: "., ,, ?, *, -, @ 는 사용할 수 없습니다.",
                    isSecure: false,
                    isTouched: viewModel.fieldStates[.nickname]?.isTouched ?? false,
                    isValid: viewModel.fieldStates[.nickname]?.isValid ?? true,
                    onTextChanged: { viewModel.updateNickname($0) },
                    onFocusChanged: { isFocused in
                        if isFocused {
                            viewModel.focusChanged(.nickname)
                            focusedField = .nickname
                        } else {
                            viewModel.fieldBlurred(.nickname)
                        }
                    }
                )
            }
            .padding(.horizontal, 32)
            
            Button(action: {
                viewModel.registerButtonTapped()
            }) {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blackSprout)
                        .foregroundStyle(.gray0)
                        .cornerRadius(10)
                } else {
                    Text("회원가입")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blackSprout)
                        .foregroundStyle(.gray0)
                        .cornerRadius(10)
                }
            }
            .disabled(viewModel.isLoading)
            .padding(.horizontal, 32)
            .padding(.top, 16)
            
            Spacer()
        }
        .background(Color(red: 235/255, green: 240/255, blue: 230/255))
        .edgesIgnoringSafeArea(.all)
        .onChange(of: focusedField) { newValue in
            viewModel.focusChanged(newValue)
        }
        .onChange(of: viewModel.registrationSuccess) { success in
            if success {
                dismiss()
            }
        }
    }
}
