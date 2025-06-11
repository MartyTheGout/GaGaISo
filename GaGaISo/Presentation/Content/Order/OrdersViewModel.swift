//
//  OrderStatusViewModel.swift
//  GaGaISo
//
//  Created by marty.academy on 6/9/25.
//

import Foundation
import Combine

class OrdersViewModel: ObservableObject {
    private let orderContext: OrderContext
    private var cancellables = Set<AnyCancellable>()
    
    @Published var currentOrders: [OrderDetailDTO] = []
    @Published var completedOrders: [OrderDetailDTO] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    init(orderContext: OrderContext) {
        self.orderContext = orderContext
        setupBindings()
    }
    
    private func setupBindings() {
        orderContext.$currentOrders
            .assign(to: &$currentOrders)
        
        orderContext.$completedOrders
            .assign(to: &$completedOrders)
        
        orderContext.$isLoadingOrders
            .assign(to: &$isLoading)
        
        orderContext.$orderLoadError
            .assign(to: &$errorMessage)
    }
    
    // MARK: - Computed Properties
    var hasCurrentOrders: Bool {
        !currentOrders.isEmpty
    }
    
    var hasCompletedOrders: Bool {
        !completedOrders.isEmpty
    }
    
    // MARK: - Public Methods
    func loadOrders() async {
        await orderContext.loadOrderRecords()
    }
    
    func refreshOrders() async {
        await orderContext.refreshOrderRecords()
    }
    
    func actionButtonTapped(for order: OrderDetailDTO) {
        // TODO: 추후 액션 구현
        print("Action button tapped for order: \(order.orderID)")
    }
}
