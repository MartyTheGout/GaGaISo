//
//  RegistrationView.swift
//  LoginFeatureExperiment
//
//  Created by marty.academy on 5/11/25.
//

import SwiftUI
import ComposableArchitecture

struct SignUpView: View {
    let store: StoreOf<SignUpFeature>
    @FocusState private var focusedField: SignUpFeature.SignUpField?
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
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
                    // 이메일 필드
                    InputField(
                        title: "이메일",
                        text: viewStore.email,
                        errorMessage: "유효한 이메일 형식이 아닙니다.",
                        isSecure: false,
                        isTouched: viewStore.fieldStates[.email]?.isTouched ?? false,
                        isValid: viewStore.fieldStates[.email]?.isValid ?? true,
                        onTextChanged: { viewStore.send(.emailChanged($0)) },
                        onFocusChanged: { isFocused in
                            if isFocused {
                                viewStore.send(.focusChanged(.email))
                                focusedField = .email
                            } else {
                                viewStore.send(.fieldBlurred(.email))
                            }
                        }
                    )
                    
                    // 비밀번호 필드
                    InputField(
                        title: "비밀번호",
                        text: viewStore.password,
                        errorMessage: "최소 8자 이상, 영문, 숫자, 특수문자(@$!%*#?&)를 포함해야합니다.",
                        isSecure: true,
                        isTouched: viewStore.fieldStates[.password]?.isTouched ?? false,
                        isValid: viewStore.fieldStates[.password]?.isValid ?? true,
                        onTextChanged: { viewStore.send(.passwordChanged($0)) },
                        onFocusChanged: { isFocused in
                            if isFocused {
                                viewStore.send(.focusChanged(.password))
                                focusedField = .password
                            } else {
                                viewStore.send(.fieldBlurred(.password))
                            }
                        }
                    )
                    
                    // 비밀번호 확인 필드
                    InputField(
                        title: "비밀번호 확인",
                        text: viewStore.confirmPassword,
                        errorMessage: "비밀번호가 일치하지 않습니다.",
                        isSecure: true,
                        isTouched: viewStore.fieldStates[.confirmPassword]?.isTouched ?? false,
                        isValid: viewStore.fieldStates[.confirmPassword]?.isValid ?? true,
                        onTextChanged: { viewStore.send(.confirmPasswordChanged($0)) },
                        onFocusChanged: { isFocused in
                            if isFocused {
                                viewStore.send(.focusChanged(.confirmPassword))
                                focusedField = .confirmPassword
                            } else {
                                viewStore.send(.fieldBlurred(.confirmPassword))
                            }
                        }
                    )
                    
                    // 닉네임 필드
                    InputField(
                        title: "닉네임",
                        text: viewStore.nickname,
                        errorMessage: "., ,, ?, *, -, @ 는 사용할 수 없습니다.",
                        isSecure: false,
                        isTouched: viewStore.fieldStates[.nickname]?.isTouched ?? false,
                        isValid: viewStore.fieldStates[.nickname]?.isValid ?? true,
                        onTextChanged: { viewStore.send(.nicknameChanged($0)) },
                        onFocusChanged: { isFocused in
                            if isFocused {
                                viewStore.send(.focusChanged(.nickname))
                                focusedField = .nickname
                            } else {
                                viewStore.send(.fieldBlurred(.nickname))
                            }
                        }
                    )
                }
                .padding(.horizontal, 32)
                
                Button(action: {
                    viewStore.send(.registerButtonTapped)
                }) {
                    if viewStore.isLoading {
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
                .disabled(viewStore.isLoading)
                .padding(.horizontal, 32)
                .padding(.top, 16)
                
                Spacer()
            }
            .background(Color(red: 235/255, green: 240/255, blue: 230/255))
            .edgesIgnoringSafeArea(.all)
            .onChange(of: focusedField) { newValue in
                viewStore.send(.focusChanged(newValue))
            }
            // 등록 성공 시 처리
            .onChange(of: viewStore.registrationSuccess) { success in
                if success {
                    // 여기서 네비게이션 뒤로 가기 등 처리
                    // 예: dismiss() 또는 navigationPath.removeLast()
                }
            }
        }
    }
}
