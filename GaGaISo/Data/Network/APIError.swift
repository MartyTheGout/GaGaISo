//
//  APIError.swift
//  LoginFeatureTest
//
//  Created by marty.academy on 5/11/25.
//

import Foundation

enum APIError: Error, CustomStringConvertible {
    case invalidResponse(statusCode: Int, url: URL?, body: String?)
    case decodingError(Error)
    case unknown(Error)
    case unauthorized(statusCode: Int, url: URL?, body: String?)

    var description: String {
        switch self {
        case .invalidResponse(let statusCode, let url, let body):
            return """
            [APIError.invalidResponse]
            - Status Code: \(statusCode)
            - URL: \(url?.absoluteString ?? "nil")
            - Body: \(body ?? "nil")
            """
        case .decodingError(let error):
            return "[APIError.decodingError] Decoding error: \(error)"
        case .unknown(let error):
            return "[APIError.unknown] Unknown error: \(error)"
        case .unauthorized(let statusCode, let url, let body):
            return """
            [APIError.unauthorized]
            - Status Code: \(statusCode)
            - URL: \(url?.absoluteString ?? "nil")
            - Body: \(body ?? "nil")
            """
        }
    }
    
    var guidance: String {
        switch self {
        case .invalidResponse(let statusCode, let url, let body):
            print("statusCode: \(statusCode)")
            print("url: \(String(describing: url))")
            print("body: \(body ?? "no-body")")
            switch statusCode {
            case 400..<500: return "required\(statusCode)\n 담당자가 확인 중입니다. 불편을 끼쳐 죄송합니다."
            case 500..<600: return "unstable\(statusCode)\n 서버가 불안정합니다. 잠시 후에 시도해주세요."
            default: return "unknown\(statusCode) 담당자가 확인 중입니다. 불편을 끼쳐 죄송합니다."
            }
        case .decodingError(let error):
            print(error)
            return "requiredDBer\n 담당자가 확인 중입니다. 불편을 끼쳐 죄송합니다."
        case .unknown(let error):
            print(error)
            return "unknown\n담당자가 확인 중입니다. 불편을 끼쳐 죄송합니다."
        case .unauthorized:
            return "unauthorized\n유효한 인증값이 아닙니다. 다시 로그인해주세요."
        }
    }
}
