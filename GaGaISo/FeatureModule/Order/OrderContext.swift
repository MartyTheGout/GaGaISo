//
//  OrderContext.swift
//  GaGaISo
//
//  Created by marty.academy on 5/26/25.
//

import Combine
import Foundation

struct OrderItem: Identifiable {
    let id: String
    let menuName: String
    let menuPrice: Int
    var quantity: Int
    
    var totalPrice: Int {
        menuPrice * quantity
    }
}

struct OrderedMenuItem {
    let menuId: String
    let name: String
    let price: Int
    let quantity: Int
}

struct CompletedOrder {
    let id : String // orderId
    let storeName: String
    let storeId: String
    let totalPrice: String
    let menuItems: [OrderedMenuItem]
    let createdAt: Date
}

enum OrderError: Error, LocalizedError {
    case invalidOrderData
    case paymentFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidOrderData:
            return "주문 정보가 올바르지 않습니다."
        case .paymentFailed:
            return "결제 처리 중 오류가 발생했습니다."
        }
    }
}

class OrderContext: ObservableObject {
    
    private let networkManager: StrategicNetworkHandler
    
    @Published private var completedOrders: [String: CompletedOrder] = [:]
    
    @Published private(set) var orderItems: [OrderItem] = []
    @Published private(set) var storeId: String?
    @Published private(set) var storeName: String?
    
    // Payment Related
    @Published var isProcessingPayment: Bool = false
    @Published var showPaymentSheet: Bool = false
    @Published var currentOrderCode: String?
    
    init(networkManager: StrategicNetworkHandler) {
        self.networkManager = networkManager
    }
    
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
        if let currentStoreId = self.storeId, currentStoreId == storeId {
            return
        }
        
        if let currentStoreId = self.storeId, currentStoreId != storeId, hasItems {
            clearOrder()
        }
        
        self.storeId = storeId
        self.storeName = storeName
    }
    
    func addMenuItem(menu: MenuList, quantity: Int) {
        let newItem = OrderItem(
            id: menu.menuID,
            menuName: menu.name,
            menuPrice: menu.price,
            quantity: quantity
        )
        
        if let existingIndex = orderItems.firstIndex(where: { $0.id == newItem.id }) {
            orderItems[existingIndex].quantity += quantity
        } else {
            orderItems.append(newItem)
        }
        
        dump(orderItems)
        
    }
    
    func changeOrderItemQuantity(menuId: String, quantity: Int) {
        guard let index = orderItems.firstIndex(where: { $0.id == menuId }) else { return }
        
        if orderItems[index].quantity + quantity > 0 {
            orderItems[index].quantity += quantity
        } else {
            remoteOrderItem(at: index)
        }
    }
    
    func remoteOrderItem(at index : Int) {
        orderItems.remove(at: index)
    }
    
    func remoteOrderItem(menuId: String) {
        guard let index = orderItems.firstIndex(where: { $0.id == menuId }) else { return }
        remoteOrderItem(at: index)
    }
    
    func clearOrder() {
        orderItems.removeAll()
        storeId = nil
        storeName = nil
    }
}

//MARK: - Payment
extension OrderContext {
    func makeOrder() async -> Result<String, Error> {
        guard let storeId = storeId, !orderItems.isEmpty else {
            return .failure(OrderError.invalidOrderData)
        }
        
        await MainActor.run {
            isProcessingPayment = true
        }
        
        let orderMenuList = orderItems.map { item in
            OrderMenuItem(menuId: item.id, quantity: item.quantity)
        }
        
        let orderRequest = PostOrderRequestDTO(
            storeId: storeId,
            orderMenuList: orderMenuList,
            totalPrice: totalPrice
        )
        
        let result = await networkManager.request(
            OrderRouter.v1PostOrder(orderDetail: orderRequest),
            type: OrderPostResultDTO.self
        )
        
        await MainActor.run {
            isProcessingPayment = false
            
            switch result {
            case .success(let orderResult):
                self.currentOrderCode = orderResult.orderCode
                self.showPaymentSheet = true
            case .failure:
                break
            }
        }
        
        return result.map {$0.orderCode}.mapError { $0 as Error }
    }
    
    func handlePaymentCompletion(success: Bool) {
        showPaymentSheet = false
        currentOrderCode = nil
        
        if success {
            clearOrder()
        }
    }
}
