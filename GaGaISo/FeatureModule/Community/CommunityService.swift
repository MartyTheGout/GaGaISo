//
//  CommunityService.swift
//  GaGaISo
//
//  Created by marty.academy on 5/31/25.
//

import Foundation

class CommunityService {
    private let networkManager: StrategicNetworkHandler
    
    init(networkManager: StrategicNetworkHandler) {
        self.networkManager = networkManager
    }
    
    func getPosts(
        category: String = "",
        latitude: Double,
        longitude: Double,
        maxDistance: String,
        limit: Int = 10,
        next: String = "",
        orderBy: CommunityOrderCriteria = .createdAt
    ) async -> Result<PostsDTO, APIError> {
        let result = await networkManager.request(
            CommunityRouter.v1GetPost(
                category: category,
                latitude: latitude,
                longitude: longitude,
                maxDistance: maxDistance,
                limit: limit,
                next: next,
                orderBy: orderBy
            ),
            type: PostsDTO.self
        )
        return result
    }
    
    func searchPosts(title: String) async -> Result<PostsDTO, APIError> {
        let result = await networkManager.request(
            CommunityRouter.v1SearchPost(title: title),
            type: PostsDTO.self
        )
        return result
    }
    
    func togglePostLike(postId: String, isLiked: Bool) async -> Result<Bool, APIError> {
        let result = await networkManager.request(
            CommunityRouter.v1LikePost(postId: postId, status: isLiked),
            type: LikeStatusDTO.self
        )
        return result.map { $0.likeStatus }
    }
    
    func getPostDetail(postId: String) async -> Result<PostDTO, APIError> {
        let result = await networkManager.request(
            CommunityRouter.v1GetPostDetail(postId: postId),
            type: PostDTO.self
        )
        return result
    }
}
