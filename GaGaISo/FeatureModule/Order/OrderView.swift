//
//  Orderview.swift
//  GaGaISo
//
//  Created by marty.academy on 6/7/25.
//

import SwiftUI


struct OrderView: View {
    @StateObject private var viewModel: OrderViewModel
    @State private var dragOffset: CGFloat = 0
    @State private var isExpanded: Bool = false
    
    private let minHeight: CGFloat = 80
    private let maxHeight: CGFloat = 500
    
    init(viewModel: OrderViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 드래그 인디케이터
            dragIndicator
            
            if isExpanded {
                expandedContent
            } else {
                collapsedContent
            }
        }
        .background(Color.gray0)
        .cornerRadius(16, corners: [.topLeft, .topRight])
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: -2)
        .offset(y: dragOffset)
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
                    
                    withAnimation(.spring()) {
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
        .animation(.spring(), value: isExpanded)
    }
    
    // MARK: - Drag Indicator
    private var dragIndicator: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(Color.gray45)
            .frame(width: 40, height: 4)
            .padding(.top, 8)
            .onTapGesture {
                withAnimation(.spring()) {
                    isExpanded.toggle()
                }
            }
    }
    
    // MARK: - Collapsed Content
    private var collapsedContent: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.storeName)
                    .pretendardFont(size: .body3, weight: .medium)
                    .foregroundColor(.gray60)
                
                Text("\(viewModel.totalItemCount)개 메뉴")
                    .pretendardFont(size: .body2, weight: .bold)
                    .foregroundColor(.gray90)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(viewModel.formattedTotalPrice)
                    .pretendardFont(size: .body1, weight: .bold)
                    .foregroundColor(.gray90)
            }
            
            Button(action: {
                // 결제하기 액션 - 비워둠
            }) {
                Text("결제하기")
                    .pretendardFont(size: .body3, weight: .bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.brightForsythia)
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .frame(height: minHeight - 20)
    }
    
    // MARK: - Expanded Content
    private var expandedContent: some View {
        VStack(spacing: 0) {
            HStack {
                Text(viewModel.storeName)
                    .pretendardFont(size: .body1, weight: .bold)
                    .foregroundColor(.gray90)
                
                Spacer()
                
                Button(action: {
                    viewModel.clearAllItems()
                }) {
                    Text("전체삭제")
                        .pretendardFont(size: .body3)
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
            
            Divider()
                .padding(.horizontal, 16)
            
            // Order Item List
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
            
            // Purchasement Section
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
                
                Button(action: {
                    // 결제하기 액션 - 비워둠
                }) {
                    Text("결제하기")
                        .pretendardFont(size: .body1, weight: .bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.brightForsythia)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .frame(maxHeight: maxHeight)
    }
}
