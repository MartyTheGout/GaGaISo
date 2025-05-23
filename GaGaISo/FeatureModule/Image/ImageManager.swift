//
//  ImageManager.swift
//  GaGaISo
//
//  Created by marty.academy on 5/23/25.
//

import Foundation
import UIKit

class ImageService {
    let networkManager: StrategicNetworkHandler
    
    init(networkManager: StrategicNetworkHandler) {
        self.networkManager = networkManager
    }
    
    func fetchImageWith(urlString: String) async -> Result<UIImage?, Error> {
        let result = await networkManager.request(ImageRouter.v1GetImage(resourcePath: urlString), type: Data.self)
        
        return result.map {
            guard let image = UIImage(data: $0) else { return nil }
            return downsizeImage(image, targetSize: CGSize(width: 250, height: 200))
            
        }.mapError { $0 as Error }
    }
    
    private func downsizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        let ratio = min(widthRatio, heightRatio)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
