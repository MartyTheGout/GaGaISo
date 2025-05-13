//
//  Router.swift
//  LoginFeatureTest
//
//  Created by marty.academy on 5/11/25.
//

import Foundation

enum TestRouter: RouterProtocol {
    case v1AuthRefresh(refreshToken: String)
    case v1ValidateEmail(email: String)
    case v1EmailJoin(email: String, password: String, nick: String, phoneNum: String, deviceToken: String)
    case v1EmailLogin(email: String, password: String, deviceToken: String)
    case v1KakaoLogin(oauthToken: String, deviceToken: String)
    case v1AppleLogin(idToken: String, deviceToken: String, nick: String)
    case v1UserProfile
    
    var baseURL: URL {
        guard let url = URL(string: ExternalDatasource.pickup.baseURLString) else {
            fatalError("[Error: Router] Couldn't find baseURL error")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .v1AuthRefresh : return "v1/auth/refresh"
        case .v1ValidateEmail : return "v1/users/validation/email"
        case .v1EmailJoin : return "v1/users/join"
        case .v1EmailLogin : return "v1/users/login"
        case .v1KakaoLogin : return "v1/users/login/kakao"
        case .v1AppleLogin: return "v1/users/login/apple"
        case .v1UserProfile: return "v1/users/me/profile"
        }
    }
    
    var parameter : [URLQueryItem] {
        switch self {
        case .v1AuthRefresh(let refreshToken) :
            return [
                URLQueryItem(name: "RefreshToken", value: refreshToken) ,
            ]
        default: return []
        }
    }
    var body: Data? {
        switch self {
        case .v1AuthRefresh:
            return nil
        case .v1ValidateEmail(let email):
            let dict = ["email": email]
            return try? JSONSerialization.data(withJSONObject: dict)
        case .v1EmailJoin(let email, let password, let nick, let phoneNum, let deviceToken):
            let dict = [
                "email": email,
                "password": password,
                "nick": nick,
                "phoneNum": phoneNum,
                "deviceToken": deviceToken
            ]
            return try? JSONSerialization.data(withJSONObject: dict)
        case .v1EmailLogin(let email, let password, let deviceToken):
            let dict = [
                "email": email,
                "password": password,
                "deviceToken": deviceToken
            ]
            return try? JSONSerialization.data(withJSONObject: dict)
        case .v1KakaoLogin(let oauthToken, let deviceToken):
            let dict = [
                "oauthToken": oauthToken,
                "deviceToken": deviceToken
            ]
            return try? JSONSerialization.data(withJSONObject: dict)
        case .v1AppleLogin(let idToken, let deviceToken, let nick):
            let dict = [
                "idToken": idToken,
                "deviceToken": deviceToken,
                "nick": nick
            ]
            return try? JSONSerialization.data(withJSONObject: dict)
        case .v1UserProfile:
            return nil  // GET 요청이므로 body 없음
        }
    }
    
    var method: String {
        switch self {
        case .v1AuthRefresh:
            return "GET"
        case .v1ValidateEmail:
            return "POST"
        case .v1EmailJoin:
            return "POST"
        case .v1EmailLogin:
            return "POST"
        case .v1KakaoLogin:
            return "POST"
        case .v1AppleLogin:
            return "POST"
        case .v1UserProfile:
            return "GET"
        }
    }
    
    var urlRequest: URLRequest {
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)
        components?.queryItems = parameter.isEmpty ? nil : parameter
        
        guard let url = components?.url else {
            fatalError("[Error: Router] Failed on generating URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
            if let body = body {
                request.httpBody = body
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue(APIKey.PICKUP, forHTTPHeaderField: "SeSACKey")
            }
        return request
    }
}
