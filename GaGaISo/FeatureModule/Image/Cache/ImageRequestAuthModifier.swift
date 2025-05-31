//
//  ImageRequestAuthModifier.swift
//  GaGaISo
//
//  Created by marty.academy on 5/31/25.
//

import Foundation
import Kingfisher

final class ImageRequestAuthModifier: ImageDownloadRequestModifier {
    
    private let authManager: AuthManagerProtocol
    
    init(authManager: AuthManagerProtocol) {
        self.authManager = authManager
    }
    
    func modified(for request: URLRequest) -> URLRequest? {
        var modifiedRequest = request
        
        if let token = authManager.getAccessToken() {
            modifiedRequest.setValue("\(token)", forHTTPHeaderField: "Authorization")
            modifiedRequest.setValue("\(APIKey.PICKUP)", forHTTPHeaderField: "SeSACKey")
        }
        
        return modifiedRequest
    }
}
