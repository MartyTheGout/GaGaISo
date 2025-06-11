//
//  OrderCardView.swift
//  GaGaISo
//
//  Created by marty.academy on 6/9/25.
//

import SwiftUI

struct OrderCardView: View {
    @StateObject private var viewModel: OrderCardViewModel
    
    let isCurrentOrder: Bool
    let onActionTapped: (() -> Void)?
    
    init(viewModel: OrderCardViewModel, isCurrentOrder: Bool, onActionTapped: (() -> Void)?) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.isCurrentOrder = isCurrentOrder
        self.onActionTapped = onActionTapped
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerSection
            
            Divider()
                .padding(.horizontal, 16)
            
            if isCurrentOrder {
                orderStatusSection
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                
                Divider()
                    .padding(.horizontal, 16)
            }
            
            menuListSection
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            
            Divider()
                .padding(.horizontal, 16)
            
            footerSection
        }
        .background(Color.gray0)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack(spacing: 12) {
            // 가게 이미지
            Group {
                if let storeImage = viewModel.storeImage {
                    Image(uiImage: storeImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else if viewModel.isStoreImageLoading {
                    ProgressView()
                        .tint(.blackSprout)
                        .scaleEffect(0.7)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray15)
                        .overlay(
                            Image(systemName: "storefront")
                                .foregroundColor(.gray60)
                        )
                }
            }
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.order.store.name)
                    .pretendardFont(size: .body2, weight: .bold)
                    .foregroundColor(.gray90)
                
                Text("주문번호: \(viewModel.order.orderCode)")
                    .pretendardFont(size: .caption1)
                    .foregroundColor(.gray60)
                
                if isCurrentOrder {
                    Text(viewModel.orderStatusDisplayName)
                        .pretendardFont(size: .caption1, weight: .medium)
                        .foregroundColor(.blackSprout)
                }
            }
            
            Spacer()
            
            // 액션 버튼 (현재 주문에만 표시)
            if isCurrentOrder, let onActionTapped = onActionTapped {
                Button(action: onActionTapped) {
                    Circle()
                        .fill(Color.brightForsythia)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "ellipsis")
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .bold))
                        )
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .onAppear {
            viewModel.loadStoreImage()
        }
    }
    
    // MARK: - Order Status Section
    private var orderStatusSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("주문 진행 상황")
                    .pretendardFont(size: .body3, weight: .medium)
                    .foregroundColor(.gray75)
                
                Spacer()
            }
            
            OrderProgressView(
                currentStatus: viewModel.order.currentOrderStatus,
                timeline: viewModel.order.orderStatusTimeline
            )
        }
    }
    
    // MARK: - Menu List Section
    private var menuListSection: some View {
        VStack(spacing: 8) {
            ForEach(Array(viewModel.order.orderMenuList.enumerated()), id: \.offset) { index, menuItem in
                HStack(spacing: 12) {
                    // 메뉴 이미지
                    OrderMenuImageView(
                        menuImageURL: menuItem.menu.menuImageURL,
                        viewModel: viewModel
                    )
                    .frame(width: 40, height: 40)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(menuItem.menu.name)
                            .pretendardFont(size: .body3, weight: .medium)
                            .foregroundColor(.gray90)
                        
                        Text("\(menuItem.menu.price)원")
                            .pretendardFont(size: .caption1)
                            .foregroundColor(.gray60)
                    }
                    
                    Spacer()
                    
                    Text("\(menuItem.quantity)개")
                        .pretendardFont(size: .body3, weight: .medium)
                        .foregroundColor(.gray75)
                }
                
                if index < viewModel.order.orderMenuList.count - 1 {
                    Divider()
                        .padding(.vertical, 4)
                }
            }
        }
    }
    
    // MARK: - Footer Section
    private var footerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.formatDate(viewModel.order.createdAt))
                    .pretendardFont(size: .caption1)
                    .foregroundColor(.gray60)
                
                if !isCurrentOrder {
                    Text("주문 완료")
                        .pretendardFont(size: .caption1, weight: .medium)
                        .foregroundColor(.deepSprout)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("총 \(viewModel.totalMenuCount)개")
                    .pretendardFont(size: .caption1)
                    .foregroundColor(.gray60)
                
                Text("\(viewModel.order.totalPrice)원")
                    .pretendardFont(size: .body2, weight: .bold)
                    .foregroundColor(.gray90)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Order Menu Image View
struct OrderMenuImageView: View {
    let menuImageURL: String
    let viewModel: OrderCardViewModel
    
    var body: some View {
        Group {
            if let menuImage = viewModel.getMenuImage(for: menuImageURL) {
                Image(uiImage: menuImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if viewModel.isLoadingMenuImage(for: menuImageURL) {
                ProgressView()
                    .tint(.blackSprout)
                    .scaleEffect(0.7)
            } else {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray15)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray60)
                            .font(.caption)
                    )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .onAppear {
            viewModel.loadMenuImage(for: menuImageURL)
        }
    }
}
