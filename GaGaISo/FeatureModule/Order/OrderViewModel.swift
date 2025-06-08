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
    
    var isProcessingPayment: Bool {
        orderContext.isProcessingPayment
    }
    
    var showPaymentSheet: Bool {
        orderContext.showPaymentSheet
    }
    
    var currentOrderCode: String? {
        orderContext.currentOrderCode
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

extension OrderViewModel {
    func startPayment() {
        Task {
            let result = await orderContext.makeOrder()
            
            await MainActor.run {
                switch result {
                case .success:
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.orderContext.showPaymentSheet = true
                    }
                    
                case .failure(let error):
                    // 토스트로 에러 표시
                    dump(error)
                    print("주문 생성 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func handlePaymentCompletion(success: Bool) {
        orderContext.handlePaymentCompletion(success: success)
    }
}
