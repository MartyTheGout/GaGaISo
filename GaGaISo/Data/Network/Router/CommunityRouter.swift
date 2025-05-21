//
//  CommunityRouter.swift
//
//
//  Created by marty.academy on 5/11/25.
//

import Foundation

enum CommunityRouter: RouterProtocol {
    
    case v1AuthRefresh(accessToken: String, refreshToken: String)
    
    var baseURL: URL {
        guard let url = URL(string: ExternalDatasource.pickup.baseURLString) else {
            fatalError("[Error: Router] Couldn't find baseURL error")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .v1AuthRefresh : return "v1/auth/refresh"
            
        }
    }
    
    var parameter : [URLQueryItem] {
        switch self {
        default: return []
        }
    }
    var body: Data? {
        switch self {
        case .v1AuthRefresh:
            return nil
        }
    }
    
    var method: String {
        switch self {
        case .v1AuthRefresh:
            return "GET"
        }
    }
}
