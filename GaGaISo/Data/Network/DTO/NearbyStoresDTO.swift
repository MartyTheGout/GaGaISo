//
//  NearbyStoresDTO.swift
//  GaGaISo
//
//  Created by marty.academy on 5/21/25.
//

import Foundation

struct NearbyStoresDTO: Codable {
    let data: [StoreDTO]
    let nextCursor: String

    enum CodingKeys: String, CodingKey {
        case data
        case nextCursor = "next_cursor"
    }
}

struct StoreDTO: Codable {
    let storeID: String
    let category: String
    let name: String
    let close: String // "21:00"
    let storeImageUrls: [String]
    let isPicchelin, isPick: Bool
    let pickCount: Int
    let hashTags: [String]
    let totalRating: Double
    let totalOrderCount, totalReviewCount: Int
    let geolocation: Geolocation
    let distance: Double
    let createdAt, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case storeID = "store_id"
        case category, name, close
        case storeImageUrls = "store_image_urls"
        case isPicchelin = "is_picchelin"
        case isPick = "is_pick"
        case pickCount = "pick_count"
        case hashTags
        case totalRating = "total_rating"
        case totalOrderCount = "total_order_count"
        case totalReviewCount = "total_review_count"
        case geolocation, distance, createdAt, updatedAt
    }
}

struct Geolocation: Codable {
    let longitude, latitude: Double
}
