//
//  MockAuthManager.swift
//  GaGaISo
//
//  Created by marty.academy on 5/19/25.
//

import Foundation

final class MockAuthManager: AuthManagerProtocol {

    var isLoggedIn: Bool = false
    var refreshResult: Bool = true
    
    var appleLoginResult: Result<Void, Error> = .success(())
    var kakaoLoginResult: Result<Void, Error> = .success(())
    var emailLoginResult: Result<Void, Error> = .success(())
    var registerResult: Result<Void, Error> = .success(())
    
    var bootstrapCalled = false
    var refreshCalled = false
    var saveTokenCalled = false
    var logoutCalled = false
    var appleLoginCalled = false
    var kakaoLoginCalled = false
    var emailLoginCalled = false
    var registerCalled = false
    
    var savedAccessToken: String?
    var savedRefreshToken: String?
    
    func bootstrap() async {
        bootstrapCalled = true
        _ = await tryRefreshIfNeeded()
    }
    
    func tryRefreshIfNeeded() async -> Bool {
        refreshCalled = true
        return refreshResult
    }
    
    func saveTokenToStore(_ accessToken: String, _ refreshToken: String) {
        saveTokenCalled = true
        savedAccessToken = accessToken
        savedRefreshToken = refreshToken
    }
    
    func logout() async {
        logoutCalled = true
        await setLoginState(false)
    }
    
    func setLoginState(_ value: Bool) async {
        isLoggedIn = value
    }
    
    func loginWithApple(idToken: String, nick: String) async -> Result<Void, Error> {
        appleLoginCalled = true
        
        if case .success = appleLoginResult {
            await setLoginState(true)
        }
        
        return appleLoginResult
    }
    
    func loginWithKakao(oauthToken: String) async -> Result<Void, Error> {
        kakaoLoginCalled = true
        
        if case .success = kakaoLoginResult {
            await setLoginState(true)
        }
        
        return kakaoLoginResult
    }
    
    func loginWithEmail(email: String, password: String) async -> Result<Void, Error> {
        emailLoginCalled = true
        
        if case .success = emailLoginResult {
            await setLoginState(true)
        }
        
        return emailLoginResult
    }
    
    func register(email: String, password: String, nickname: String) async -> Result<Void, Error> {
        registerCalled = true
        
        if case .success = registerResult {
            await setLoginState(true)
        }
        
        return registerResult
    }
}
