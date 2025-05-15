//
//  NetworkManager.swift
//  LoginFeatureTest
//
//  Created by marty.academy on 5/11/25.
//

import Foundation


final class RawNetworkClient {
    func request<T: Decodable>(_ request: URLRequest, responseType: T.Type) async -> Result<T, APIError> {
        
        let (data, response): (Data, URLResponse)
        
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            return .failure(.unknown(error))
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            return .failure(.invalidResponse(statusCode: -1, url: request.url, body: nil))
        }
        
        guard httpResponse.statusCode == 200 else {
            return .failure(.invalidResponse(statusCode: httpResponse.statusCode, url: request.url, body: String(data: data, encoding: .utf8)))
        }
        
        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return .success(decoded)
        } catch {
            return .failure(APIError.decodingError(error))
        }
    }
}

final class StrategicNetworkHandler {
    private let client: RawNetworkClient
    private let authManager: AuthenticationManager

    init(client: RawNetworkClient, authManager: AuthenticationManager) {
        self.client = client
        self.authManager = authManager
    }

    func request<T: Decodable>(_ route: RouterProtocol, type: T.Type) async -> Result<T, APIError> {
        let request = route.urlRequest
        
        let result: Result<T, APIError> = await client.request(request, responseType: T.self)

        if case .failure(let error) = result, case .invalidResponse(let code, _, _) = error, [401, 403].contains(code) {
            let refreshed = await authManager.tryRefreshIfNeeded()
            if refreshed {
                return await client.request(request, responseType: type) // retry
            } else {
                return .failure(error)
            }
        }

        return result
    }
}

//struct NetworkHandler {
//    
//    private let authManager: AuthenticationManager
//    
//    init(authManager: AuthenticationManager) {
//        self.authManager = authManager
//    }
//    
//    func request<T: Decodable>(_ endpoint: RouterProtocol, type: T.Type) async -> Result<T, APIError> {
//        
//        let request = endpoint.urlRequest
//        
//        let (data, response): (Data, URLResponse)
//        
//        do {
//            (data, response) = try await URLSession.shared.data(for: request)
//        } catch {
//            return .failure(APIError.unknown(error))
//        }
//        
//        guard let httpResponse = response as? HTTPURLResponse else {
//            return .failure(APIError.invalidResponse(statusCode: -1, url: request.url, body: nil))
//        }
//        
//        if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
//            let success = await authManager.tryRefresh()
//            if success {
//                return await request(endpoint, type: type)
//            } else {
//                await authManager.logout()
//                return .failure(.unauthorized)
//            }
//        }
//        
//        guard httpResponse.statusCode == 200 else {
//            let responseBody = String(data: data, encoding: .utf8)
//            return .failure(
//                APIError.invalidResponse(
//                    statusCode: httpResponse.statusCode,
//                    url: request.url,
//                    body: responseBody
//                )
//            )
//        }
//        
//        do {
//            let decoded = try JSONDecoder().decode(T.self, from: data)
//            return .success(decoded)
//        } catch {
//            return .failure(APIError.decodingError(error))
//        }
//    }
//}
