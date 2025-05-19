//
//  AuthManagerProtocol.swift
//  GaGaISo
//
//  Created by marty.academy on 5/19/25.
//

import Foundation

protocol AuthManagerProtocol {
    var isLoggedIn: Bool { get }
    
    func bootstrap() async
    func tryRefreshIfNeeded() async -> Bool
    func saveTokenToStore(_ accessToken: String, _ refreshToken: String)
    func logout() async
    func setLoginState(_ value: Bool) async
    
    func loginWithApple(idToken: String, nick: String) async -> Result<Void, Error>
    func loginWithKakao(oauthToken: String) async -> Result<Void, Error>

    func loginWithEmail(email: String, password: String) async -> Result<Void, Error>
    func register(email: String, password: String, nickname: String) async -> Result<Void, Error>
}
