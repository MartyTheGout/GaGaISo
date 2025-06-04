//
//  PostItemViewModel.swift
//  GaGaISo
//
//  Created by marty.academy on 5/31/25.
//


import Foundation
import Combine
import UIKit
import CoreLocation

class PostItemViewModel: ObservableObject {
    let postId: String
    
    private let communityContext: CommunityContext
    private let imageContext: ImageContext
    private let locationManager: LocationManager
    private var cancellables = Set<AnyCancellable>()
    
    @Published var postImages: [UIImage] = []
    @Published var isImageLoading: Bool = false
    @Published var imageLoadError: String?
    
    var post: PostDTO? {
        communityContext.post(for: postId)
    }
    
    init(postId: String, communityContext: CommunityContext, imageContext: ImageContext, locationManager: LocationManager) {
        self.postId = postId
        self.communityContext = communityContext
        self.imageContext = imageContext
        self.locationManager = locationManager
        
        communityContext.$posts
            .map { $0[postId] }
            .removeDuplicates(by: { oldPost, newPost in
                oldPost?.postID == newPost?.postID &&
                oldPost?.isLike == newPost?.isLike &&
                oldPost?.likeCount == newPost?.likeCount
            })
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    func loadPostImages() {
        guard let post, !post.files.isEmpty else { return }
        
        guard postImages.isEmpty && !isImageLoading else { return }
        
        isImageLoading = true
        imageLoadError = nil
        
        let imagesToLoad = Array(post.files.prefix(3))
        
        Task {
            for imageUrl in imagesToLoad {
                let result = await imageContext.fetchImageWith(urlString: imageUrl)
                
                await MainActor.run {
                    switch result {
                    case .success(let image):
                        if let image = image {
                            self.postImages.append(image)
                        }
                    case .failure(let error):
                        self.imageLoadError = error.localizedDescription
                    }
                }
            }
            
            await MainActor.run {
                self.isImageLoading = false
            }
        }
    }
    
    func toggleLike() {
        Task {
            await communityContext.toggleLike(for: postId)
        }
    }
}

extension PostItemViewModel {
    var hasPost: Bool {
        communityContext.post(for: postId) != nil
    }
    
    var title: String {
        post?.title ?? "로딩 중..."
    }
    
    var content: String {
        post?.content ?? ""
    }
    
    var authorName: String {
        post?.creator.nick ?? "알 수 없음"
    }
    
    var userId : String {
        post?.creator.userID ?? ""
    }
    
    var isLiked: Bool {
        post?.isLike ?? false
    }
    
    var likeCount: Int {
        post?.likeCount ?? 0
    }
    
    var likeCountText: String {
        let count = likeCount
        if count >= 1000 {
            return "\(count/1000)K"
        }
        return "\(count)"
    }
    
    var createdAt: String {
        guard let post = post else { return "" }
        
        let dateFormatter = ISO8601DateFormatter()
        guard let date = dateFormatter.date(from: post.createdAt) else { return "" }
        
        let now = Date()
        let timeInterval = now.timeIntervalSince(date)
        
        if timeInterval < 60 {
            return "방금 전"
        } else if timeInterval < 3600 {
            return "\(Int(timeInterval / 60))분 전"
        } else if timeInterval < 86400 {
            return "\(Int(timeInterval / 3600))시간 전"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "M월 d일"
            return formatter.string(from: date)
        }
    }
    
    var distance: String {
        guard let post = post,
              let currentLocation = locationManager.location else {
            return "---"
        }
        
        let postLocation = CLLocation(
            latitude: post.geolocation.latitude,
            longitude: post.geolocation.longitude
        )
        
        let distanceInMeters = currentLocation.distance(from: postLocation)
        
        if distanceInMeters < 1000 {
            return "\(Int(distanceInMeters))M"
        } else {
            return String(format: "%.1fKM", distanceInMeters / 1000)
        }
    }
    
    var storeName: String {
        post?.store.name ?? ""
    }
    
    var hasStore: Bool {
        guard let post = post else { return false }
        return !post.store.name.isEmpty
    }
    
    var imageUrls: [String] {
        post?.files ?? []
    }
    
    var hasImages: Bool {
        !imageUrls.isEmpty
    }
    
    var displayImageCount: Int {
        min(imageUrls.count, 3)
    }
    
    var additionalImageCount: Int {
        max(0, imageUrls.count - 3)
    }
}
