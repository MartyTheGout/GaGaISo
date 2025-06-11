//
//  OrderViewModel.swift
//  GaGaISo
//
//  Created by marty.academy on 6/7/25.
//

import Foundation
import Combine

class OrderViewModel: ObservableObject {
    private let orderContext: OrderContext
    
    @Published var showPaymentSheet: Bool = false
    @Published var isProcessingPayment: Bool = false
    @Published var currentOrderCode: String?
    
    init(orderContext: OrderContext) {
        self.orderContext = orderContext
        setupBindings()
    }
    
    private func setupBindings() {
        orderContext.$showPaymentSheet
            .assign(to: &$showPaymentSheet) // cancellable 이 없다 이래도 되는것인가?
        
        orderContext.$isProcessingPayment
            .assign(to: &$isProcessingPayment)
        
        orderContext.$currentOrderCode
            .assign(to: &$currentOrderCode)
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

extension OrderViewModel {
    func startPayment() {
        Task {
            let result = await orderContext.makeOrder()
            
            await MainActor.run {
                switch result {
                case .success:
                    break
                case .failure(let error):
                    dump(error)
                    print("주문 생성 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func handlePaymentCompletion(success: Bool, orderUniqueId : String) async {
        await orderContext.handlePaymentCompletion(success: success, orderUniqueId: orderUniqueId)
    }
}
