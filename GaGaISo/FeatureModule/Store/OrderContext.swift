//
//  OrderContext.swift
//  GaGaISo
//
//  Created by marty.academy on 5/26/25.
//

import Combine
import Foundation

struct OrderItem: Identifiable {
    let id = UUID()
    let menuId: String
    let menuName: String
    let menuPrice: Int
    var quantity: Int
    
    var totalPrice: Int {
        menuPrice * quantity
    }
}

class OrderContext: ObservableObject {
    @Published private(set) var orderItems: [OrderItem] = []
    @Published private(set) var storeId: String?
    @Published private(set) var storeName: String?
    
    var totalItemCount: Int {
        orderItems.reduce(0) { $0 + $1.quantity }
    }
    
    var totalPrice: Int {
        orderItems.reduce(0) { $0 + $1.totalPrice }
    }
    
    var hasItems: Bool {
        !orderItems.isEmpty
    }
    
    func startNewOrder(storeId: String, storeName: String) {
        self.storeId = storeId
        self.storeName = storeName
        orderItems.removeAll()
    }
    
    func addMenuItem(menu: MenuList, quantity: Int) {
        let newItem = OrderItem(
            menuId: menu.menuID,
            menuName: menu.name,
            menuPrice: menu.price,
            quantity: quantity
        )
        
        if let existingIndex = orderItems.firstIndex(where: { $0.menuId == newItem.menuId }) {
            orderItems[existingIndex].quantity += quantity
        } else {
            orderItems.append(newItem)
        }
    }
    
    func clearOrder() {
        orderItems.removeAll()
        storeId = nil
        storeName = nil
    }
}
