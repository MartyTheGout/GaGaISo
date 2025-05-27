//
//  LoginViewModel.swift
//  GaGaISo
//
//  Created by marty.academy on 5/21/25.
//

import Foundation
import Combine
import AuthenticationServices

class LoginViewModel: ObservableObject {
    @Published var email: String = "chichi@gmail.com"
    @Published var password: String = "asdf1234!"
    @Published var isShowingSignUp = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let authManager: AuthManagerProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(authManager: AuthManagerProtocol) {
        self.authManager = authManager
    }
    
    func loginButtonTapped() {
        isLoading = true
        
        Task {
            let result = await authManager.loginWithEmail(email: email, password: password)
            
            await MainActor.run {
                isLoading = false
                
                switch result {
                case .success:
                    // Login successful - handled through authManager.isLoggedIn in AppEntryView
                    break
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func signUpButtonTapped() {
        isShowingSignUp = true
    }
    
    func signUpDismissed() {
        isShowingSignUp = false
    }
}
