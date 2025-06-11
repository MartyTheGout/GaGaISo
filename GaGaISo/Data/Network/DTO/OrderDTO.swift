//
//  OrderDTO.swift
//  GaGaISo
//
//  Created by marty.academy on 6/6/25.
//

import Foundation

// MARK: - Order Request DTOs
struct PostOrderRequestDTO: Codable {
    let storeId: String
    let orderMenuList: [OrderMenuItem]
    let totalPrice: Int
    
    enum CodingKeys: String, CodingKey {
        case storeId = "store_id"
        case orderMenuList = "order_menu_list"
        case totalPrice = "total_price"
    }
}

struct OrderMenuItem: Codable {
    let menuId: String
    let quantity: Int
    
    enum CodingKeys: String, CodingKey {
        case menuId = "menu_id"
        case quantity
    }
}

struct OrderDetailsDTO: Codable {
    let data: [OrderDetailDTO]
}

// MARK: - OrderDetailDTO
struct OrderDetailDTO: Codable {
    let orderID, orderCode: String
    let totalPrice: Int
    let review: Review?
    let store: StoreInOrder
    let orderMenuList: [OrderMenuList]
    let currentOrderStatus: String
    let orderStatusTimeline: [OrderStatusTimeline]
    let paidAt, createdAt, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case orderID = "order_id"
        case orderCode = "order_code"
        case totalPrice = "total_price"
        case review, store
        case orderMenuList = "order_menu_list"
        case currentOrderStatus = "current_order_status"
        case orderStatusTimeline = "order_status_timeline"
        case paidAt, createdAt, updatedAt
    }
}

// MARK: - OrderMenuList
struct OrderMenuList: Codable {
    let menu: Menu
    let quantity: Int
}

// MARK: - Menu
struct Menu: Codable {
    let id, category, name, description: String
    let originInformation: String
    let price: Int
    let tags: [String]
    let menuImageURL, createdAt, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id, category, name, description
        case originInformation = "origin_information"
        case price, tags
        case menuImageURL = "menu_image_url"
        case createdAt, updatedAt
    }
}

// MARK: - OrderStatusTimeline
struct OrderStatusTimeline: Codable {
    let status: String
    let completed: Bool
    let changedAt: String?
}

// MARK: - Review
struct Review: Codable {
    let id: String
    let rating: Int
}

// MARK: - StoreInOrder
struct StoreInOrder: Codable {
    let id, category, name, close: String
    let storeImageUrls, hashTags: [String]
    let geolocation: Geolocation
    let createdAt, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id, category, name, close
        case storeImageUrls = "store_image_urls"
        case hashTags, geolocation, createdAt, updatedAt
    }
}

// MARK: - StoreInOrder
struct OrderPostResultDTO: Codable {
    let orderID, orderCode: String
    let totalPrice: Int
    let createdAt, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case orderID = "order_id"
        case orderCode = "order_code"
        case totalPrice = "total_price"
        case createdAt, updatedAt
    }
}
