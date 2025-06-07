//
//  OrderViewModel.swift
//  GaGaISo
//
//  Created by marty.academy on 6/7/25.
//

import Foundation

class OrderViewModel: ObservableObject {
    private let orderContext: OrderContext
    
    init(orderContext: OrderContext) {
        self.orderContext = orderContext
    }
    
    // MARK: - Published Properties
    var orderItems: [OrderItem] {
        orderContext.orderItems
    }
    
    var storeName: String {
        orderContext.storeName ?? ""
    }
    
    var totalItemCount: Int {
        orderContext.totalItemCount
    }
    
    var totalPrice: Int {
        orderContext.totalPrice
    }
    
    var formattedTotalPrice: String {
        "\(totalPrice)원"
    }
    
    var hasItems: Bool {
        orderContext.hasItems
    }
    
    // MARK: - Actions
    func increaseQuantity(for item: OrderItem) {
        orderContext.changeOrderItemQuantity(menuId: item.id, quantity: 1)
    }
    
    func decreaseQuantity(for item: OrderItem) {
        orderContext.changeOrderItemQuantity(menuId: item.id, quantity: -1)
    }
    
    func removeItem(for item: OrderItem) {
        orderContext.remoteOrderItem(menuId: item.id)
    }
    
    func clearAllItems() {
        orderContext.clearOrder()
    }
}
