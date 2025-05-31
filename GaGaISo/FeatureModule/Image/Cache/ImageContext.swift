//
//  ImageContext.swift
//  GaGaISo
//
//  Created by marty.academy on 5/31/25.
//

import Foundation
import UIKit
import Kingfisher

class ImageContext {
    private let authManager: AuthManagerProtocol
    private let imageCache : ImageCache
    private let imageDownloader : ImageDownloader
    
    private let maxMemoryCost: Int = 100 * 1024 * 1024  // 100MB
    private let maxDiskSize: UInt = 500 * 1024 * 1024   // 500MB
    private let maxCacheAge: TimeInterval = 7 * 24 * 60 * 60  // 7 days
    
    init(authManager: AuthManagerProtocol) {
        self.authManager = authManager
        
        self.imageCache = ImageCache(name: "GaGaIsoImageCache")
        self.imageCache.memoryStorage.config.totalCostLimit = maxMemoryCost
        self.imageCache.diskStorage.config.sizeLimit = maxDiskSize
        self.imageCache.diskStorage.config.expiration = .seconds(maxCacheAge)
        
        self.imageDownloader = ImageDownloader(name: "GaGaISOImageDownloader")
        self.imageDownloader.sessionConfiguration.timeoutIntervalForRequest = 15
        self.imageDownloader.sessionConfiguration.timeoutIntervalForResource = 30
        
        KingfisherManager.shared.cache = self.imageCache
        KingfisherManager.shared.downloader = self.imageDownloader
    }
    
    func fetchImageWith(urlString: String) async -> Result<UIImage?, KingfisherError> {
        guard let url = URL(string: urlString) else {
            return .failure(.imageSettingError(reason: .emptySource)) // modify later
        }
        
        let modifier = ImageRequestAuthModifier(authManager: authManager)
        let processor = DownsamplingImageProcessor(size: CGSize(width: 250, height: 200)) // modify later
        
        let options: KingfisherOptionsInfo = [
            .requestModifier(modifier),
            .processor(processor),
            .cacheOriginalImage, // Not only downSized, but also with original Image => cache
            .backgroundDecode, // Decoding in background
            .callbackQueue(.mainAsync)
        ]
        
        return await performImageRequest(url:url, options: options)
    }
    
    private func performImageRequest(url: URL, options: KingfisherOptionsInfo) async -> Result<UIImage?, KingfisherError> {
        await withCheckedContinuation { (continuation: CheckedContinuation<Result<UIImage?, KingfisherError>, Never>) in
            KingfisherManager.shared.retrieveImage(
                with: url,
                options: options
            ) { [weak self] result in
                
                switch result {
                case .success(let value):
                    continuation.resume(returning: .success(value.image))
                case .failure(let error):
                    if self?.isAuthError(error) == true {
                        Task {
                            let retryResult = await self?.retryWithTokenRefresh(url: url, options: options)
                            continuation.resume(returning: retryResult ?? .failure(error))
                        }
                    } else {
                        continuation.resume(returning: .failure(error))
                    }
                }
            }
        }
    }
    
    private func retryWithTokenRefresh(url: URL, options: KingfisherOptionsInfo) async -> Result<UIImage?, KingfisherError> {
        let refreshed = await authManager.tryRefreshIfNeeded()
        
        guard refreshed else {
            return .failure(.requestError(reason: .emptyRequest))
        }
        
        // getaccessToken is not stored property, calcualted everytime when get called. so no need to have manual update.
//        let updatedOptions = options.map { option in
//            if case .requestModifier = option {
//                return .requestModifier(ImageRequestAuthModifier(authManager: authManager))
//            }
//            return option
//        }
        
        return await withCheckedContinuation { (continuation: CheckedContinuation<Result<UIImage?, KingfisherError>, Never>) in
            KingfisherManager.shared.retrieveImage(
                with: url,
                options: options
            ) { result in
                switch result {
                case .success(let retrieveResult):
                    continuation.resume(returning: .success(retrieveResult.image))
                case .failure(let error):
                    continuation.resume(returning: .failure(error))
                }
            }
        }
    }
    
    private func isAuthError(_ error: KingfisherError) -> Bool {
        if case .responseError(let reason) = error,
           case .invalidHTTPStatusCode(let response) = reason {
            return response.statusCode == 401 || response.statusCode == 419
        }
        return false
    }
    
    func clearCache() {
        imageCache.clearMemoryCache()
        imageCache.clearDiskCache()
    }
    
    func clearMemoryCache() {
        imageCache.clearMemoryCache()
    }
}
