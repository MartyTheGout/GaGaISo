//
//  RegistrationViewModel.swift
//  GaGaISo
//
//  Created by marty.academy on 5/14/25.
//

import ComposableArchitecture
import Foundation


@Reducer
struct SignUpFeature {
    enum SignUpField: Hashable {
        case email, password, confirmPassword, nickname
    }
    
    struct State: Equatable {
        var email = ""
        var password = ""
        var confirmPassword = ""
        var nickname = ""
        var isLoading = false
        var errorMessage: String? = nil
        var focusedField: SignUpField? = nil
        
        var fieldStates: [SignUpField: FieldState] = [
            .email: FieldState(),
            .password: FieldState(),
            .confirmPassword: FieldState(),
            .nickname: FieldState()
        ]
        
        var registrationSuccess = false
    }
    
    struct FieldState: Equatable {
        var isTouched = false
        var isValid = true
    }
    
    @CasePathable
    enum Action: Equatable {
        case emailChanged(String)
        case passwordChanged(String)
        case confirmPasswordChanged(String)
        case nicknameChanged(String)
        case focusChanged(SignUpField?)
        case fieldBlurred(SignUpField)
        case registerButtonTapped
        case registrationResponse(TaskResult<Bool>)
    }
    
    @Dependency(\.networkClient) var networkClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .emailChanged(email):
                state.email = email
                return .none
                
            case let .passwordChanged(password):
                state.password = password
                return .none
                
            case let .confirmPasswordChanged(confirmPassword):
                state.confirmPassword = confirmPassword
                return .none
                
            case let .nicknameChanged(nickname):
                state.nickname = nickname
                return .none
                
            case let .focusChanged(field):
                state.focusedField = field
                
                if let field = field {
                    state.fieldStates[field]?.isTouched = true
                }
                return .none
                
            case let .fieldBlurred(field):
                if state.fieldStates[field]?.isTouched == true {
                    switch field {
                    case .email:
                        state.fieldStates[field]?.isValid = isValidEmail(state.email)
                    case .password:
                        state.fieldStates[field]?.isValid = isValidPassword(state.password)
                    case .confirmPassword:
                        state.fieldStates[field]?.isValid = state.confirmPassword == state.password
                    case .nickname:
                        state.fieldStates[field]?.isValid = isValidNickname(state.nickname)
                    }
                }
                return .none
                
            case .registerButtonTapped:
                state.fieldStates[.email]?.isValid = isValidEmail(state.email)
                state.fieldStates[.email]?.isTouched = true
                
                state.fieldStates[.password]?.isValid = isValidPassword(state.password)
                state.fieldStates[.password]?.isTouched = true
                
                state.fieldStates[.confirmPassword]?.isValid = state.confirmPassword == state.password
                state.fieldStates[.confirmPassword]?.isTouched = true
                
                state.fieldStates[.nickname]?.isValid = isValidNickname(state.nickname)
                state.fieldStates[.nickname]?.isTouched = true
                
                let allValid = state.fieldStates.values.allSatisfy { $0.isValid }
                
                if !allValid {
                    return .none
                }
                
                state.isLoading = true
                
                return .run { [email = state.email, password = state.password, nickname = state.nickname] send in
                    await send(.registrationResponse(
                        TaskResult {
                            let response = await networkClient.request(
                                AuthenticationRouter.v1EmailJoin(
                                    email: email,
                                    password: password,
                                    nick: nickname,
                                    phoneNum: nil,
                                    deviceToken: nil
                                ).urlRequest,
                                responseType: LoginResponse.self
                            )
                            
                            switch response {
                            case .success:
                                return true
                            case .failure(let error):
                                return false
                            }
                        }
                    ))
                }
                
            case let .registrationResponse(.success(success)):
                state.isLoading = false
                state.registrationSuccess = success
                return .none
                
            case .registrationResponse(.failure(let error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
            }
        }
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = #"^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$"#
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    private func isValidNickname(_ nickname: String) -> Bool {
        let forbiddenCharacters: CharacterSet = CharacterSet(charactersIn: ".,?*-@")
        return nickname.rangeOfCharacter(from: forbiddenCharacters) == nil
    }
}
