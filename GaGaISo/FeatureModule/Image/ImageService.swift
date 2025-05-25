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


class MockImageService: ImageService {
    override func fetchImageWith(urlString: String) async -> Result<UIImage?, Error> {
        // Mock 이미지 생성 (실제로는 네트워크에서 가져올 이미지)
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5초 지연
        
        // 시스템 이미지를 사용한 Mock UIImage 생성
        let systemImageName: String
        switch urlString {
        case let url where url.contains("menu"):
            systemImageName = "photo.fill"
        default:
            systemImageName = "photo"
        }
        
        if let image = UIImage(systemName: systemImageName) {
            // 시스템 이미지를 실제 이미지처럼 보이게 하기 위해 렌더링
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: 300, height: 200))
            let renderedImage = renderer.image { context in
                UIColor.systemGray3.setFill()
                context.fill(CGRect(x: 0, y: 0, width: 300, height: 200))
                
                image.withTintColor(.systemGray, renderingMode: .alwaysOriginal)
                    .draw(in: CGRect(x: 125, y: 75, width: 50, height: 50))
            }
            return .success(renderedImage)
        }
        
        return .failure(NSError(domain: "MockImageService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Image not found"]))
    }
}
