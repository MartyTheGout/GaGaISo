//
//  Orderview.swift
//  GaGaISo
//
//  Created by marty.academy on 6/7/25.
//

import SwiftUI
import Toasts

struct OrderView: View {
    @Environment(\.presentToast) private var presentToast
    private let navigationManager = AppNavigationManager.shared
    
    @StateObject private var viewModel: OrderViewModel
    @State private var dragOffset: CGFloat = 0
    @State private var isExpanded: Bool = false
    
    private let minHeight: CGFloat = 80
    private let maxHeight: CGFloat = 500
    
    init(viewModel: OrderViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    private var yOffset: CGFloat {
        let hiddenHeight = maxHeight - minHeight
        let baseOffset = isExpanded ? 0 : hiddenHeight
        return baseOffset + dragOffset
    }
    
    var body: some View {
        VStack(spacing: 0) {
            dragIndicator
            
            headerSection
            
            Divider()
                .padding(.horizontal, 16)
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.orderItems) { item in
                        OrderItemRowView(
                            item: item,
                            onIncrease: { viewModel.increaseQuantity(for: item) },
                            onDecrease: { viewModel.decreaseQuantity(for: item) },
                            onRemove: { viewModel.removeItem(for: item) }
                        )
                        
                        if item.id != viewModel.orderItems.last?.id {
                            Divider()
                                .padding(.horizontal, 16)
                        }
                    }
                }
            }
            .frame(maxHeight: 300)
            
            Divider()
                .padding(.horizontal, 16)
            
            paymentSection
        }
        .frame(height: maxHeight)
        .background(Color.gray0)
        .cornerRadius(16, corners: [.topLeft, .topRight])
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: -2)
        .offset(y: yOffset)
        .clipped() // 화면 밖 부분은 잘림
        .gesture(
            DragGesture()
                .onChanged { value in
                    let translation = value.translation.height
                    
                    if isExpanded {
                        // 확장된 상태에서는 아래로만 드래그 가능
                        dragOffset = max(0, translation)
                    } else {
                        // 축소된 상태에서는 위로만 드래그 가능
                        dragOffset = min(0, translation)
                    }
                }
                .onEnded { value in
                    let translation = value.translation.height
                    let velocity = value.velocity.height
                    
                    withAnimation(.easeOut(duration: 0.01)) {
                        if isExpanded {
                            // 확장된 상태에서 아래로 드래그시 축소
                            if translation > 100 || velocity > 500 {
                                isExpanded = false
                            }
                        } else {
                            // 축소된 상태에서 위로 드래그시 확장
                            if translation < -50 || velocity < -300 {
                                isExpanded = true
                            }
                        }
                        
                        dragOffset = 0
                    }
                }
        )
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isExpanded)
        .sheet(isPresented: $viewModel.showPaymentSheet) {
            if let orderCode = viewModel.currentOrderCode {
                
                IamportPaymentView(
                    orderCode: orderCode,
                    totalPrice: viewModel.totalPrice,
                    storeName: viewModel.storeName
                ) { response in
                    
                    guard let response, let success = response.success, let uid = response.imp_uid else { return }
                    
                    Task {
                        await viewModel.handlePaymentCompletion(success: success, orderUniqueId: uid)
                        
                        let toast = ToastValue(
                            icon: Image(systemName: success ? "checkmark.circle" : "xmark.circle"),
                            message: success ? "결제가 완료되었습니다!" : "결제가 취소되었습니다.",
                            duration: 3.0
                        )
                        
                        presentToast(toast)
                        
                        navigationManager.handleOrderCompletion()
                    }
                }
            }
        }
    }
    
    // MARK: - Drag Indicator
    private var dragIndicator: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(Color.gray45)
            .frame(width: 40, height: 4)
            .padding(.top, 8)
            .onTapGesture {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.storeName)
                    .pretendardFont(size: isExpanded ? .body1 : .body3, weight: isExpanded ? .bold : .medium)
                    .foregroundColor(isExpanded ? .gray90 : .gray60)
                
                if !isExpanded {
                    Text("\(viewModel.totalItemCount)개 메뉴")
                        .pretendardFont(size: .body2, weight: .bold)
                        .foregroundColor(.gray90)
                }
            }
            
            Spacer()
            
            if isExpanded {
                // expanded version's header
                Button(action: {
                    viewModel.clearAllItems()
                }) {
                    Text("전체삭제")
                        .pretendardFont(size: .body3)
                        .foregroundColor(.red)
                }
            } else {
                // summarized version
                VStack(alignment: .trailing, spacing: 4) {
                    Text(viewModel.formattedTotalPrice)
                        .pretendardFont(size: .body1, weight: .bold)
                        .foregroundColor(.gray90)
                }
                
                paymentButton(isCompact: true)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, isExpanded ? 12 : 16)
        .frame(height: isExpanded ? nil : minHeight - 20)
    }
    
    // MARK: - Payment Section
    private var paymentSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("총 \(viewModel.totalItemCount)개")
                    .pretendardFont(size: .body2)
                    .foregroundColor(.gray60)
                
                Spacer()
                
                Text(viewModel.formattedTotalPrice)
                    .pretendardFont(size: .title1, weight: .bold)
                    .foregroundColor(.gray90)
            }
            
            paymentButton(isCompact: false)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }
    
    private func paymentButton(isCompact: Bool) -> some View {
        Button(action: { viewModel.startPayment() }) {
            Group {
                if viewModel.isProcessingPayment {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(.white)
                        Text("처리중...")
                            .pretendardFont(size: isCompact ? .body3 : .body1, weight: .bold)
                            .foregroundColor(.white)
                    }
                } else {
                    Text("결제하기")
                        .pretendardFont(size: isCompact ? .body3 : .body1, weight: .bold)
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: isCompact ? nil : .infinity)
            .padding(.vertical, isCompact ? 8 : 16)
            .padding(.horizontal, isCompact ? 16 : 0)
            .background(.brightForsythia)
            .cornerRadius(isCompact ? 8 : 12)
        }
        .disabled(viewModel.isProcessingPayment)
    }
}
