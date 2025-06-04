//
//  AuthManager.swift
//  GaGaISo
//
//  Created by marty.academy on 5/14/25.
//

import Foundation
import RealmSwift

final class AuthenticationManager: ObservableObject, AuthManagerProtocol {
    @Published var isLoggedIn: Bool = false
    
    private let client: RawNetworkClient
    
    private let authStore: AuthStore
    private let deviceToken : String?
    
    init(authStore: AuthStore, networkClient: RawNetworkClient) {
        self.authStore = authStore
        self.deviceToken = authStore.deviceToken
        self.client = networkClient
    }
    
    func bootstrap() async {
        await tryRefreshIfNeeded()
    }
    
    @discardableResult
    func tryRefreshIfNeeded() async -> Bool {
        guard let accessToken = authStore.accessToken,
              let refreshToken = authStore.refreshToken else {
            print("no accessToken, or no refresh Token ")
            return false
        }
        let request = AuthenticationRouter.v1AuthRefresh(accessToken: accessToken, refreshToken: refreshToken).createRequest(withToken: accessToken)
        let result: Result<TokenRefresheResponseDTO, APIError> = await client.request(request, responseType: TokenRefresheResponseDTO.self)
        
        switch result {
            
        case .success(let tokens):
            saveTokenToStore(tokens.accessToken, tokens.refreshToken)
            await MainActor.run { self.isLoggedIn = true }
            return true
        case .failure:
            await logout()
            return false
        }
    }
    
    func saveTokenToStore(_ accessToken: String, _ refreshToken: String) {
        authStore.accessToken = accessToken
        authStore.refreshToken = refreshToken
    }
    
    func logout() async {
        authStore.clear()
        await setLoginState(false)
    }
    
    func setLoginState(_ value: Bool) async {
        await MainActor.run {
            self.isLoggedIn = value
        }
    }
    
    func getAccessToken() -> String? {
        return authStore.accessToken
    }
}

//MARK: - Sign up with Apple
extension AuthenticationManager {
    func loginWithApple(idToken: String, nick: String) async -> Result<Void, Error> {
        let response = await client.request(
            AuthenticationRouter.v1AppleLogin(
                idToken: idToken,
                deviceToken: deviceToken ?? "",
                nick: nick
            ).createRequest(withToken: nil),
            responseType: LoginResponseDTO.self
        )
        
        switch response {
        case .success(let result):
            saveTokenToStore(result.accessToken, result.refreshToken)
            RealmCurrentUser.setCurrentUser(userId: result.user_id, nick: result.nick)
            await setLoginState(true)
            return .success(())
            
        case .failure(let error):
            await setLoginState(false)
            return .failure(error)
        }
    }
}

//MARK: - Sign up with Kakao
extension AuthenticationManager {
    func loginWithKakao(oauthToken: String) async -> Result<Void, Error> {
        let response = await client.request(
            AuthenticationRouter.v1KakaoLogin(
                oauthToken: oauthToken,
                deviceToken: deviceToken ?? ""
            ).createRequest(withToken: nil),
            responseType: LoginResponseDTO.self
        )
        
        switch response {
        case .success(let result):
            saveTokenToStore(result.accessToken, result.refreshToken)
            RealmCurrentUser.setCurrentUser(userId: result.user_id, nick: result.nick)
            await setLoginState(true)
            return .success(())
            
        case .failure(let error):
            await setLoginState(false)
            return .failure(error)
        }
    }
}

//MARK: - Sign up
extension AuthenticationManager {
    func loginWithEmail(
        email: String,
        password: String
    ) async -> Result<Void, Error> {
        let response = await client.request(
            AuthenticationRouter.v1EmailLogin(email: email, password: password, deviceToken: deviceToken ?? "" ).createRequest(withToken: nil),
            responseType: LoginResponseDTO.self
        )
        
        switch response {
        case .success(let result):
            saveTokenToStore(result.accessToken, result.refreshToken)
            RealmCurrentUser.setCurrentUser(userId: result.user_id, nick: result.nick)
            await setLoginState(true)
            return .success(())
        case .failure(let error):
            await setLoginState(false)
            return .failure(error)
        }
    }
    
    func register(email: String, password: String, nickname: String) async -> Result<Void, Error> {
        let response = await client.request(AuthenticationRouter.v1EmailJoin(email: email, password: password, nick: nickname, phoneNum: nil, deviceToken: nil).createRequest(withToken: nil), responseType: LoginResponseDTO.self)
        
        switch response {
        case .success(let result):
            saveTokenToStore(result.accessToken, result.refreshToken)
            RealmCurrentUser.setCurrentUser(userId: result.user_id, nick: result.nick)
            await setLoginState(true)
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }
}
