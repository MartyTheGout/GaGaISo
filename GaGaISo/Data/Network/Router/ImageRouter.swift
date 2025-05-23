//
//  StoreRouter.swift
//
//
//  Created by marty.academy on 5/11/25.
//

import Foundation

enum ImageRouter: RouterProtocol {
    case v1GetImage(resourcePath: String)

    var baseURL: URL {
        guard let url = URL(string: ExternalDatasource.pickup.baseURLString) else {
            fatalError("[Error: Router] Couldn't find baseURL error")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .v1GetImage(let resourcePath):
            return "v1\(resourcePath)"
        }
    }
    
    var parameter : [URLQueryItem] {
        switch self {
        default: return []
        }
    }
    var body: Data? {
        switch self {
        default: return nil
        }
    }
    
    var method: String {
        switch self {
        default: return "GET"
        }
    }
}
