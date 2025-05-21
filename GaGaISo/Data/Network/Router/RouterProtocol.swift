//
//  RouterProtocol.swift
//  LoginFeatureTest
//
//  Created by marty.academy on 5/11/25.
//

import Foundation


protocol RouterProtocol {
    var baseURL: URL { get }
    var path: String { get }
    var parameter: [URLQueryItem] { get }
    var method: String { get }
    var body: Data? { get }
    var baseHeaders: [String: String] { get }
    func createRequest(withToken accessToken: String?) -> URLRequest
}

extension RouterProtocol {
    var baseHeaders: [String: String] {
        return [
            "Content-Type": "application/json",
            "SeSACKey": APIKey.PICKUP
        ]
    }
    
    func createRequest(withToken accessToken: String?) -> URLRequest {
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)
        components?.queryItems = parameter.isEmpty ? nil : parameter
        
        guard let url = components?.url else {
            fatalError("[Error: Router] Failed on generating URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        if let body = body {
            request.httpBody = body
        }
        
        var headers = baseHeaders
        
        if let token = accessToken {
            headers["Authorization"] = token
        }
        
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        return request
    }
}
