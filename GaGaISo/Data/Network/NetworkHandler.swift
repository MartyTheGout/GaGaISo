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
    private let authManager: AuthManagerProtocol
    
    private let maxTimeoutRetryAttempts = 3
    private let baseDelaySeconds: Double = 1.0

    init(client: RawNetworkClient, authManager: AuthManagerProtocol) {
        self.client = client
        self.authManager = authManager
    }

    func request<T: Decodable>(_ route: RouterProtocol, type: T.Type) async -> Result<T, APIError> {
        return await requestWithTimeoutRetry(route, type: type, attempt: 1)
    }
    
    private func requestWithTimeoutRetry<T: Decodable>(
        _ route: RouterProtocol,
        type: T.Type,
        attempt: Int
    ) async -> Result<T, APIError> {
        let request = route.createRequest(withToken: authManager.getAccessToken())
        let result: Result<T, APIError> = await client.request(request, responseType: T.self)
        
        print("===========================================")
        dump(request)
        dump(result)
        print("===========================================")
        
        // Single retry after token refresh (no exponential backoff)
        if case .failure(let error) = result,
           case .invalidResponse(let code, _, _) = error,
           code == 419 {
            
            let refreshed = await authManager.tryRefreshIfNeeded()
            if refreshed {
                return await client.request(request, responseType: type)
            } else {
                return .failure(error)
            }
        }
        
        // Handle timeout errors with retry strategy
        if case .failure(let error) = result,
           isTimeoutError(error),
           attempt <= maxTimeoutRetryAttempts {
            print("⏱️ Timeout on attempt \(attempt). Retrying...")
            
            let delay = calculateRetryDelay(attempt: attempt)
            print("⏳ Waiting \(String(format: "%.2f", Double(delay) / 1_000_000_000))s before retry...")
            
            try? await Task.sleep(nanoseconds: delay)
            
            return await requestWithTimeoutRetry(route, type: type, attempt: attempt + 1)
        }
        
        return result
    }
    
    private func isTimeoutError(_ error: APIError) -> Bool {
        switch error {
        case .unknown(let underlyingError):
            if let urlError = underlyingError as? URLError {
                return urlError.code == .timedOut ||
                       urlError.code == .networkConnectionLost ||
                       urlError.code == .notConnectedToInternet
            }
            return false
        default:
            return false
        }
    }
    
    private func calculateRetryDelay(attempt: Int) -> UInt64 {
        // Exponential backoff: baseDelay * 2^(attempt-1)
        let exponentialDelay = baseDelaySeconds * pow(2.0, Double(attempt - 1))
        
        // Add random jitter (±25%) to avoid thundering herd
        let jitterRange = 0.25
        let jitter = Double.random(in: (1.0 - jitterRange)...(1.0 + jitterRange))
        
        let finalDelaySeconds = exponentialDelay * jitter
        
        // Convert to nanoseconds
        return UInt64(finalDelaySeconds * 1_000_000_000)
    }
}
