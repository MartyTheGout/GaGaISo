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
