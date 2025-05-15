//
//  AuthManager.swift
//  GaGaISo
//
//  Created by marty.academy on 5/14/25.
//

import Foundation

final class AuthenticationManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    
    private let client: RawNetworkClient
    
    private let authStore: AuthStore
    private let deviceToken : String?
    
    init(authStore: AuthStore, networkClient: RawNetworkClient ) {
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
            return false
        }
        let request = AuthenticationRouter.v1AuthRefresh(accessToken: accessToken, refreshToken: refreshToken).urlRequest
        let result: Result<TokenRefresheResponse, APIError> = await client.request(request, responseType: TokenRefresheResponse.self)
        
        switch result {
            
        case .success(let tokens):
            authStore.accessToken = tokens.accessToken
            authStore.refreshToken = tokens.refreshToken
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
}

//MARK: - Sign up with Apple
extension AuthenticationManager {
    func loginWithApple(idToken: String, nick: String, completion: @escaping (Bool) -> Void) async {
        let response = await client.request(
            AuthenticationRouter.v1AppleLogin(
                idToken: idToken,
                deviceToken: deviceToken ?? "",
                nick: nick
            ).urlRequest,
            responseType: LoginResponse.self
        )
        
        switch response {
        case .success(let result):
            saveTokenToStore(result.accessToken, result.refreshToken)
            dump(result)
            await setLoginState(true)
            completion(true)
            
        case .failure(let error):
            print("❌ Apple Login 실패: \(error)")
            completion(false)
            await setLoginState(false)
        }
    }
}

//MARK: - Sign up with Kakao
extension AuthenticationManager {
    func loginWithKakao(
        oauthToken: String,
        completion: @escaping (Bool) -> Void
    ) async {
        let response = await client.request(
            AuthenticationRouter.v1KakaoLogin(
                oauthToken: oauthToken,
                deviceToken: deviceToken ?? ""
            ).urlRequest,
            responseType: LoginResponse.self
        )
        
        switch response {
        case .success(let result):
            saveTokenToStore(result.accessToken, result.refreshToken)
            await setLoginState(true)
            completion(true)
        case .failure(let error):
            print("❌ Kakao Login 실패: \(error)")
            completion(false)
            await setLoginState(false)
        }
    }
}

//MARK: - Sign up
extension AuthenticationManager {
    func loginWithEmail(
        email: String,
        password: String
    ) async {
        let response = await client.request(
            AuthenticationRouter.v1EmailLogin(email: email, password: password, deviceToken: deviceToken ?? "" ).urlRequest,
            responseType: LoginResponse.self
        )
        
        switch response {
        case .success(let result):
            saveTokenToStore(result.accessToken, result.refreshToken)
            await setLoginState(true)
        case .failure(let error):
            print("❌ Email Login 실패: \(error)")
            await setLoginState(false)
        }
    }
    
    func register(email: String, password: String, nickname: String, completion: @escaping () -> Void) async  {
        let response = await client.request(AuthenticationRouter.v1EmailJoin(email: email, password: password, nick: nickname, phoneNum: nil, deviceToken: nil).urlRequest, responseType: LoginResponse.self)
        
        switch response {
        case .success(let result):
            saveTokenToStore(result.accessToken, result.refreshToken)
            completion()
        case .failure(let error):
            print(error)
        }
    }
}

