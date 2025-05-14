//
//  AuthManager.swift
//  GaGaISo
//
//  Created by marty.academy on 5/14/25.
//

import Foundation

final class AuthenticationManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    
    private let authStore: AuthStore
    private let deviceToken : String?
    
    init(authStore: AuthStore ) {
        self.authStore = authStore
        self.deviceToken = authStore.deviceToken
    }
    
    func bootstrap() async {
        guard let accessToken = authStore.accessToken, let refreshToken = authStore.refreshToken else {
            print("There is no accessToken in keyChain")
            await logout()
            return
        }
        
        print("Refresh Process is working ")
        await tryRefresh(accessToken: accessToken, refreshToken: refreshToken)
    }
    
    func tryRefresh(accessToken: String, refreshToken: String) async {
        let response = await NetworkHandler.request(AuthenticationRouter.v1AuthRefresh(accessToken: accessToken, refreshToken: refreshToken), type: TokenRefresheResponse.self)
        switch response {
        case .success(let response) :
            saveTokenToStore(response.accessToken, response.refreshToken)
            await setLoginState(true)
            
        case.failure(let error):
            print("❗️ accessToken 만료됨. refresh 시도")
            print(error)
            await logout()
        }
    }
    
    func register(email: String, password: String, nickname: String, completion: @escaping () -> Void) async  {
        let response = await NetworkHandler.request(AuthenticationRouter.v1EmailJoin(email: email, password: password, nick: nickname, phoneNum: nil, deviceToken: nil), type: LoginResponse.self)
        
        switch response {
        case .success(let result):
            saveTokenToStore(result.accessToken, result.refreshToken)
            completion()
        case .failure(let error):
            print(error)
        }
    }
    
    func saveTokenToStore(_ accessToken: String, _ refreshToken: String) {
        authStore.accessToken = accessToken
        authStore.refreshToken = refreshToken
        print(authStore.accessToken)
        print(authStore.refreshToken)
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
        let response = await NetworkHandler.request(
            AuthenticationRouter.v1AppleLogin(
                idToken: idToken,
                deviceToken: deviceToken ?? "",
                nick: nick
            ),
            type: LoginResponse.self
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
        let response = await NetworkHandler.request(
            AuthenticationRouter.v1KakaoLogin(
                oauthToken: oauthToken,
                deviceToken: deviceToken ?? ""
            ),
            type: LoginResponse.self
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

