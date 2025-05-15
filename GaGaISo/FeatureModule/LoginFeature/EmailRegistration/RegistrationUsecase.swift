//
//  RegistrationViewModel.swift
//  GaGaISo
//
//  Created by marty.academy on 5/14/25.
//

import Foundation

class RegistrationUsecase: ObservableObject {
    
    @Published var isLoading = false
    
    let networkClient: RawNetworkClient
    
    init(networkClient: RawNetworkClient) {
        self.networkClient = networkClient
    }
    
    func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = #"^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$"#
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    func isValidNickname(_ nickname: String) -> Bool {
        let forbiddenCharacters: CharacterSet = CharacterSet(charactersIn: ".,?*-@")
        return nickname.rangeOfCharacter(from: forbiddenCharacters) == nil
    }
    
    func register(email: String, password: String, nickname: String, completion: @escaping () -> Void) async {
        isLoading = true
        defer { isLoading = false }
        
        let response = await networkClient.request(AuthenticationRouter.v1EmailJoin(email: email, password: password, nick: nickname, phoneNum: nil, deviceToken: nil).urlRequest, responseType: LoginResponse.self)
        
        switch response {
        case .success:
            completion()
        case .failure(let error):
            print(error)
        }
    }
}
