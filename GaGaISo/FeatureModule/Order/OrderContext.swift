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
    
    @Published private(set) var orderItems: [OrderItem] = []
    @Published private(set) var storeId: String?
    @Published private(set) var storeName: String?
    
    // Payment Related
    @Published var isProcessingPayment: Bool = false
    @Published var showPaymentSheet: Bool = false
    @Published var currentOrderCode: String?
    
    // Order Record
    @Published private(set) var orderRecords: [OrderDetailDTO] = []
    @Published private(set) var currentOrders: [OrderDetailDTO] = []
    @Published private(set) var completedOrders: [OrderDetailDTO] = []
    @Published private(set) var isLoadingOrders: Bool = false
    @Published private(set) var orderLoadError: String?
    
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
        DispatchQueue.main.async { [weak self] in
            self?.orderItems.removeAll()
            self?.storeId = nil
            self?.storeName = nil
        }
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
    
    func handlePaymentCompletion(success: Bool, orderUniqueId: String) async {
        DispatchQueue.main.async { [weak self]  in
            self?.showPaymentSheet = false
            self?.currentOrderCode = nil
        }
        
        let validationResult = await validatePayment(with: orderUniqueId)
        
        if success && validationResult {
            clearOrder()
        }
    }
}

//MARK: - Order Record
extension OrderContext {
    func loadOrderRecords() async {
        await MainActor.run {
            isLoadingOrders = true
            orderLoadError = nil
        }
        
        let result = await networkManager.request(OrderRouter.v1GetOrder, type: OrderDetailsDTO.self)
        
        await MainActor.run {
            switch result {
            case .success(let orderDetails):
                self.orderRecords = orderDetails.data.sorted {
                    // 최신순 정렬 (ISO8601 문자열 비교)
                    $0.createdAt > $1.createdAt
                }
                self.updateOrderSections()
            case .failure(let error):
                self.orderLoadError = error.localizedDescription
            }
            self.isLoadingOrders = false
        }
    }
    
    private func updateOrderSections() {
        currentOrders = orderRecords.filter { $0.currentOrderStatus != "PICKED_UP" }
        completedOrders = orderRecords.filter { $0.currentOrderStatus == "PICKED_UP" }
    }
    
    func refreshOrderRecords() async {
        await loadOrderRecords()
    }
}


//MARK: - Payment
extension OrderContext {
    func validatePayment(with paymentUniqueId : String) async -> Bool {
        let result = await networkManager.request(OrderRouter.v1PostPayment(importId: paymentUniqueId ), type: OrderValidationDTO.self)
        
        return await MainActor.run {
            switch result {
            case .success(let data):
                return true
            case .failure(let error):
                print(error.localizedDescription)
                return false
            }
        }
    }
}
