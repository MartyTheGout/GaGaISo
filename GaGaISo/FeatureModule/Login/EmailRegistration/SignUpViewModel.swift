//
//  SignUpViewModel.swift
//  GaGaISo
//
//  Created by marty.academy on 5/21/25.
//

import Foundation
import Combine

enum SignUpField: Hashable, CaseIterable {
    case email, password, confirmPassword, nickname
}

struct FieldState: Equatable {
    var isTouched = false
    var isValid = true
}

class SignUpViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var nickname = ""
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var focusedField: SignUpField? = nil
    @Published var fieldStates: [SignUpField: FieldState] = [
        .email: FieldState(),
        .password: FieldState(),
        .confirmPassword: FieldState(),
        .nickname: FieldState()
    ]
    @Published var registrationSuccess = false
    
    private let authManager: AuthManagerProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(authManager: AuthManagerProtocol) {
        self.authManager = authManager
    }
    
    func updateEmail(_ value: String) {
        email = value
    }
    
    func updatePassword(_ value: String) {
        password = value
    }
    
    func updateConfirmPassword(_ value: String) {
        confirmPassword = value
    }
    
    func updateNickname(_ value: String) {
        nickname = value
    }
    
    func focusChanged(_ field: SignUpField?) {
        focusedField = field
        
        if let field = field {
            fieldStates[field]?.isTouched = true
        }
    }
    
    func fieldBlurred(_ field: SignUpField) {
        if fieldStates[field]?.isTouched == true {
            validateField(field)
        }
    }
    
    private func validateField(_ field: SignUpField) {
        switch field {
        case .email:
            fieldStates[field]?.isValid = isValidEmail(email)
        case .password:
            fieldStates[field]?.isValid = isValidPassword(password)
        case .confirmPassword:
            fieldStates[field]?.isValid = confirmPassword == password
        case .nickname:
            fieldStates[field]?.isValid = isValidNickname(nickname)
        }
    }
    
    func registerButtonTapped() {
        for field in SignUpField.allCases {
            fieldStates[field]?.isTouched = true
            validateField(field)
        }
        
        let allValid = fieldStates.values.allSatisfy { $0.isValid }
        
        if !allValid {
            return
        }
        
        isLoading = true
        
        Task {
            let result = await authManager.register(
                email: email,
                password: password,
                nickname: nickname
            )
            
            await MainActor.run {
                isLoading = false
                
                switch result {
                case .success:
                    registrationSuccess = true
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
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
