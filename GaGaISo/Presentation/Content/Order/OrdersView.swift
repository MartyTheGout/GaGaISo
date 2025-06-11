//
//  OrderStausView.swift
//  GaGaISo
//
//  Created by marty.academy on 6/9/25.
//

import SwiftUI

struct OrdersView: View {
    @Environment(\.diContainer) private var diContainer
    @StateObject private var viewModel: OrdersViewModel
    
    init(viewModel: OrdersViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if viewModel.isLoading && !viewModel.hasCurrentOrders && !viewModel.hasCompletedOrders {
                    loadingView
                } else {
                    if viewModel.hasCurrentOrders {
                        currentOrdersSection
                    }
                    
                    if viewModel.hasCompletedOrders {
                        completedOrdersSection
                    }
                    
                    if !viewModel.hasCurrentOrders && !viewModel.hasCompletedOrders && !viewModel.isLoading {
                        emptyStateView
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .refreshable {
                await viewModel.refreshOrders()
            }
            .onAppear {
                Task {
                    await viewModel.loadOrders()
                }
            }
            .alert("오류", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("확인") {}
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }
    
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(.blackSprout)
            
            Text("주문 내역을 불러오는 중...")
                .pretendardFont(size: .body2)
                .foregroundColor(.gray60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "bag")
                .font(.system(size: 60))
                .foregroundColor(.gray45)
            
            Text("아직 주문 내역이 없어요")
                .pretendardFont(size: .body1, weight: .bold)
                .foregroundColor(.gray60)
            
            Text("새로운 주문을 시작해보세요!")
                .pretendardFont(size: .body3)
                .foregroundColor(.gray45)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
    }
    
    // MARK: - Current Orders Section
    private var currentOrdersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "주문 현황", subtitle: "\(viewModel.currentOrders.count)개")
            
            LazyVStack(spacing: 12) {
                ForEach(viewModel.currentOrders, id: \.orderID) { order in
                    OrderCardView(
                        viewModel: diContainer.getOrderCardViewModel(order: order),
                        isCurrentOrder: true,
                        onActionTapped: {
                            viewModel.actionButtonTapped(for: order)
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - Completed Orders Section
    private var completedOrdersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "이전 주문 내역", subtitle: "\(viewModel.completedOrders.count)개")
            
            LazyVStack(spacing: 12) {
                ForEach(viewModel.completedOrders, id: \.orderID) { order in
                    OrderCardView(
                        viewModel: diContainer.getOrderCardViewModel(order: order),
                        isCurrentOrder: false,
                        onActionTapped: nil
                    )
                }
            }
        }
    }
    
    // MARK: - Section Header
    private func sectionHeader(title: String, subtitle: String) -> some View {
        HStack {
            Text(title)
                .pretendardFont(size: .body1, weight: .bold)
                .foregroundColor(.gray90)
            
            Text(subtitle)
                .pretendardFont(size: .body2)
                .foregroundColor(.gray60)
            
            Spacer()
        }
    }
}
