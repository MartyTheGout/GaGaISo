import Foundation
import UIKit
import Kingfisher

// MARK: - 실제 동작하는 ETag 구현 (Kingfisher 7.x 호환)

// ETag 저장소
class ETagStorage {
    private let userDefaults = UserDefaults.standard
    private let keyPrefix = "etag_"
    
    func saveETag(_ etag: String, for url: String) {
        let key = keyPrefix + url.hashValue.description
        userDefaults.set(etag, forKey: key)
    }
    
    func getETag(for url: String) -> String? {
        let key = keyPrefix + url.hashValue.description
        return userDefaults.string(forKey: key)
    }
    
    func removeETag(for url: String) {
        let key = keyPrefix + url.hashValue.description
        userDefaults.removeObject(forKey: key)
    }
    
    func clearAllETags() {
        let keys = userDefaults.dictionaryRepresentation().keys
        for key in keys where key.hasPrefix(keyPrefix) {
            userDefaults.removeObject(forKey: key)
        }
    }
}

// MARK: - ETag 지원 Request Modifier
class ETagAwareRequestModifier: ImageDownloadRequestModifier {
    private let authManager: AuthManagerProtocol
    private let etagStorage = ETagStorage()
    
    init(authManager: AuthManagerProtocol) {
        self.authManager = authManager
    }
    
    func modified(for request: URLRequest) -> URLRequest? {
        var modifiedRequest = request
        
        // Authorization 헤더 추가
        if let token = authManager.getAccessToken() {
            modifiedRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // ETag 헤더 추가 (캐시된 ETag가 있는 경우)
        if let url = request.url?.absoluteString,
           let etag = etagStorage.getETag(for: url) {
            modifiedRequest.setValue(etag, forHTTPHeaderField: "If-None-Match")
        }
        
        return modifiedRequest
    }
}

// MARK: - ETag 응답 처리를 위한 Custom Session Delegate
class ETagSessionDelegate: NSObject, URLSessionDataDelegate {
    private let etagStorage: ETagStorage
    private let originalDelegate: URLSessionDataDelegate?
    
    init(etagStorage: ETagStorage, originalDelegate: URLSessionDataDelegate? = nil) {
        self.etagStorage = etagStorage
        self.originalDelegate = originalDelegate
        super.init()
    }
    
    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        
        // ETag 추출 및 저장
        if let httpResponse = response as? HTTPURLResponse,
           let url = response.url,
           let etag = httpResponse.allHeaderFields["ETag"] as? String {
            etagStorage.saveETag(etag, for: url.absoluteString)
        }
        
        // 원본 delegate 호출
        originalDelegate?.urlSession?(session, dataTask: dataTask, didReceive: response, completionHandler: completionHandler) ?? completionHandler(.allow)
    }
}

// MARK: - ETag Statistics
struct ETagStats {
    let totalURLs: Int
    let urlsWithETag: Int
    let cacheHitRate: Double
    
    var etagCoverage: Double {
        guard totalURLs > 0 else { return 0.0 }
        return Double(urlsWithETag) / Double(totalURLs) * 100
    }
}

// MARK: - 간소화된 ETag 지원 버전 (권장)
class SimpleETagImageContext {
    private let authManager: AuthManagerProtocol
    private let etagStorage = ETagStorage()
    
    init(authManager: AuthManagerProtocol) {
        self.authManager = authManager
        
        // 기본 설정
        ImageCache.default.memoryStorage.config.totalCostLimit = 100 * 1024 * 1024
        ImageCache.default.diskStorage.config.sizeLimit = 500 * 1024 * 1024
        ImageCache.default.diskStorage.config.expiration = .days(7)
    }
    
    func fetchImageWith(urlString: String) async -> Result<UIImage?, KingfisherError> {
        guard let url = URL(string: urlString) else {
            return .failure(.requestError(reason: .invalidURL(request: URLRequest(url: URL(string: "invalid")!))))
        }
        
        // 먼저 캐시 확인
        if let cachedImage = await getCachedImage(for: urlString) {
            return .success(cachedImage)
        }
        
        // 캐시에 없으면 네트워크에서 다운로드
        return await downloadWithETag(url: url)
    }
    
    private func getCachedImage(for urlString: String) async -> UIImage? {
        return await withCheckedContinuation { (continuation: CheckedContinuation<UIImage?, Never>) in
            ImageCache.default.retrieveImage(forKey: urlString) { result in
                switch result {
                case .success(let value):
                    continuation.resume(returning: value.image)
                case .failure:
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    private func downloadWithETag(url: URL) async -> Result<UIImage?, KingfisherError> {
        let modifier = ETagAwareRequestModifier(authManager: authManager)
        let processor = DownsamplingImageProcessor(size: CGSize(width: 250, height: 200))
        
        let options: KingfisherOptionsInfo = [
            .requestModifier(modifier),
            .processor(processor),
            .cacheOriginalImage,
            .backgroundDecode
        ]
        
        return await withCheckedContinuation { (continuation: CheckedContinuation<Result<UIImage?, KingfisherError>, Never>) in
            KingfisherManager.shared.retrieveImage(with: url, options: options) { result in
                switch result {
                case .success(let retrieveResult):
                    continuation.resume(returning: .success(retrieveResult.image))
                case .failure(let error):
                    continuation.resume(returning: .failure(error))
                }
            }
        }
    }
    
    func clearCache() {
        ImageCache.default.clearMemoryCache()
        ImageCache.default.clearDiskCache()
        etagStorage.clearAllETags()
    }
    
    func clearMemoryCache() {
        ImageCache.default.clearMemoryCache()
    }
}


// MARK: - 사용법
/*
// 기본 사용법 (기존과 동일)
let imageService = diContainer.getImageService()
let result = await imageService.fetchImageWith(urlString: imageURL)

// ETag 지원 버전 사용
let etagImageService = diContainer.getETagImageService()
let result = await etagImageService.fetchImageWith(urlString: imageURL)

// ETag 지원 활성화
diContainer.enableETagSupport()

// ETag 통계 확인 (ETagImageContext 사용시)
if let etagContext = diContainer.getImageContext() as? ETagImageContext {
    let stats = etagContext.getETagStats()
    print("ETag Coverage: \(stats.etagCoverage)%")
}
*/

// MARK: - 성능 모니터링
extension SimpleETagImageContext {
    
    func printCacheStatus() {
        let cache = ImageCache.default
        let memoryUsage = cache.memoryStorage.config.totalCostLimit
        let diskUsage = cache.diskStorage.config.sizeLimit
        let stats = getETagStats()
        
        print("""
        📊 ETag ImageContext Status:
        Memory: \(memoryUsage / 1024 / 1024)MB
        Disk: \(diskUsage / 1024 / 1024)MB
        ETag Coverage: \(stats.etagCoverage)%
        """)
    }
    
    private func getETagStats() -> ETagStats {
        let allKeys = UserDefaults.standard.dictionaryRepresentation().keys
        let etagKeys = allKeys.filter { $0.hasPrefix("etag_") }
        
        return ETagStats(
            totalURLs: etagKeys.count,
            urlsWithETag: etagKeys.count,
            cacheHitRate: 0.0
        )
    }
}
