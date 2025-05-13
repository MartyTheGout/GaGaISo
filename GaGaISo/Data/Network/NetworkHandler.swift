//
//  NetworkManager.swift
//  LoginFeatureTest
//
//  Created by marty.academy on 5/11/25.
//

import Foundation

struct NetworkHandler {
    private init() {}
    static func request<T: Decodable>(_ endpoint: RouterProtocol, type: T.Type) async -> Result<T, APIError> {
        
        let request = endpoint.urlRequest
        
        let (data, response): (Data, URLResponse)
        
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            return .failure(APIError.unknown(error))
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            return .failure(APIError.invalidResponse(statusCode: -1, url: request.url, body: nil))
        }
        
        guard httpResponse.statusCode == 200 else {
            let responseBody = String(data: data, encoding: .utf8)
            return .failure(
                APIError.invalidResponse(
                statusCode: httpResponse.statusCode,
                url: request.url,
                body: responseBody
                )
            )
        }
        
        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return .success(decoded)
        } catch {
            return .failure(APIError.decodingError(error))
        }
    }
}
