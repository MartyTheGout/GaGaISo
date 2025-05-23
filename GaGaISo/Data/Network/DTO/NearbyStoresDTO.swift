//
//  NearbyStoresDTO.swift
//  GaGaISo
//
//  Created by marty.academy on 5/21/25.
//

import Foundation

struct NearbyStoresDTO: Decodable {
    var data: [StoreDTO]
    var nextCursor: String

    enum CodingKeys: String, CodingKey {
        case data
        case nextCursor = "next_cursor"
    }
}

struct StoreDTO: Decodable {
    var storeID: String
    var category: String
    var name: String
    var close: String // "21:00"
    var storeImageUrls: [String]
    var isPicchelin, isPick: Bool
    var pickCount: Int
    var hashTags: [String]
    var totalRating: Double
    var totalOrderCount, totalReviewCount: Int
    var geolocation: Geolocation
    var distance: Double?
    var createdAt, updatedAt: String

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
    var longitude, latitude: Double
}
