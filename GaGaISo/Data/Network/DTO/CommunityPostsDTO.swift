//
//  CommunityPostsDTO.swift
//  GaGaISo
//
//  Created by marty.academy on 5/29/25.
//

import Foundation


struct PostsDTO: Codable {
    let data: [PostDTO]
    let nextCursor: String

    enum CodingKeys: String, CodingKey {
        case data
        case nextCursor = "next_cursor"
    }
}

struct PostDTO: Codable {
    let postID, category, title, content: String
    let store: Store
    let geolocation: Geolocation
    let creator: Creator
    let files: [String]
    var isLike: Bool
    var likeCount: Int
    let createdAt, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case postID = "post_id"
        case category, title, content, store, geolocation, creator, files
        case isLike = "is_like"
        case likeCount = "like_count"
        case createdAt, updatedAt
    }
}

struct Store: Codable {
    let id, category, name, close: String
    let storeImageUrls: [String]
    let isPicchelin, isPick: Bool
    let pickCount: Int
    let hashTags: [String]
    let totalRating, totalOrderCount, totalReviewCount: Int
    let geolocation: Geolocation
    let createdAt, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id, category, name, close
        case storeImageUrls = "store_image_urls"
        case isPicchelin = "is_picchelin"
        case isPick = "is_pick"
        case pickCount = "pick_count"
        case hashTags
        case totalRating = "total_rating"
        case totalOrderCount = "total_order_count"
        case totalReviewCount = "total_review_count"
        case geolocation, createdAt, updatedAt
    }
}
