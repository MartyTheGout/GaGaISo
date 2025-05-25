//
//  File.swift
//  GaGaISo
//
//  Created by marty.academy on 5/25/25.
//

import SwiftUI

struct StoreDetailView: View {
    @StateObject var viewModel: StoreDetailViewModel
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.diContainer) var diContainer
    
    @State private var currentImageIndex = 0
    @State private var selectedMenuCategory = "전체"
    
    init(viewModel: StoreDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 0) {
                    imageSliderSection
                    
                    storeInfoSection
                        .background(Color.gray15)
                        .cornerRadius(25, corners: [.topLeft, .topRight])
                        .offset(y: -25)
                }
            }
            .ignoresSafeArea(.container, edges: .top)
            
            VStack {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.gray0)
                            .padding(8)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        Task {
                            await viewModel.toggleLike(for: viewModel.storeId)
                        }
                    }) {
                        Image(systemName: viewModel.isPick ? "heart.fill" : "heart")
                            .font(.title2)
                            .foregroundColor(viewModel.isPick ? .red : .gray0)
                            .padding(8)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.top, 4)
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            Task {
                await viewModel.loadStoreDetail()
            }
        }
    }
    
    // MARK: - 커스텀 네비게이션 바
    private var customNavigationBar: some View {
        VStack {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.gray0)
                        .padding(8)
                        .background(Color.black.opacity(0.3))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Button(action: {
                    Task {
                        await viewModel.toggleLike(for: viewModel.storeId)
                    }
                }) {
                    Image(systemName: viewModel.isPick ? "heart.fill" : "heart")
                        .font(.title2)
                        .foregroundColor(viewModel.isPick ? .red : .gray0)
                        .padding(8)
                        .background(Color.black.opacity(0.3))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)
            .padding(.top, 50)
            
            Spacer()
        }
    }
    
    // MARK: - 이미지 슬라이더 섹션
    private var imageSliderSection: some View {
        ZStack(alignment: .bottom) {
            if viewModel.storeImages.isEmpty {
                if viewModel.isImageLoading {
                    ZStack {
                        Color.gray.opacity(0.3)
                        ProgressView()
                            .tint(.blackSprout)
                    }
                } else {
                    ZStack {
                        Color.gray.opacity(0.3)
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                            .font(.largeTitle)
                    }
                }
            } else {
                TabView(selection: $currentImageIndex) {
                    ForEach(0..<viewModel.storeImages.count, id: \.self) { index in
                        Image(uiImage: viewModel.storeImages[index])
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                if viewModel.storeImages.count > 1 {
                    HStack(spacing: 8) {
                        ForEach(0..<viewModel.storeImages.count, id: \.self) { index in
                            Circle()
                                .fill(currentImageIndex == index ? Color.white : Color.white.opacity(0.5))
                                .frame(width: 8, height: 8)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .frame(height: 300)
        .clipped()
    }
    
    // MARK: - 가게 정보 섹션
    private var storeInfoSection: some View {
        VStack(alignment: .leading) {
            // 가게 기본 정보
            storeBasicInfo
                .padding(.horizontal)
                .padding(.bottom)
            
            // 가게 상세 정보
            storeDetailInfo
                .padding(.horizontal)
                .padding(.bottom)
            
            // 예상 소요시간
            estimatedTimeSection
                .padding(.horizontal)
                .padding(.bottom)
            
            Divider().background(.brightSprout)
            
            // 메뉴 필터 및 목록
            menuSection
                .background(.gray0)
        }
        .padding(.top, 25)
    }
    
    // MARK: - 가게 기본 정보
    private var storeBasicInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(viewModel.name)
                    .pretendardFont(size: .title1, weight: .bold)
                    .foregroundColor(.gray90)
                
                if viewModel.isPicchelin {
                    HStack {
                        Image(systemName: "paperplane.fill")
                            .font(.caption2)
                        Text("픽슐랭")
                            .font(.caption2)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.blackSprout)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                Spacer()
            }
            
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.brightForsythia)
                        .font(.caption)
                    
                    Text("\(viewModel.pickCount)개")
                        .pretendardFont(size: .body2)
                        .foregroundColor(.gray60)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.brightForsythia)
                        .font(.caption)
                    
                    Text(viewModel.totalRating)
                        .pretendardFont(size: .body2, weight: .bold)
                        .foregroundColor(.gray90)
                    
                    Text("(\(viewModel.totalReviewCount))")
                        .pretendardFont(size: .body2)
                        .foregroundColor(.gray60)
                }
                
                HStack(spacing: 4) {
                    Text("총 누적 주문" + viewModel.totalOrderCount)
                        .pretendardFont(size: .body3)
                        .foregroundColor(.gray60)
                }
            }
        }
    }
    
    private var storeDetailInfo: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Text("가게주소")
                    .pretendardFont(size: .body2)
                    .foregroundColor(.gray60)
                    .padding(.trailing, 8)
                    
                
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(.deepSprout)
                
                Text(viewModel.storeDetail?.address ?? "주소 정보 없음")
                    .lineLimit(2)
                    .pretendardFont(size: .body2)
                    .foregroundColor(.gray60)
                
            }
            .padding(.top, 4)
            .padding(.horizontal,8)
            
            HStack(alignment: .top) {
                Text("영업시간")
                    .pretendardFont(size: .body2)
                    .foregroundColor(.gray60)
                    .padding(.trailing, 8)
                
                Image(systemName: "clock.fill")
                    .foregroundColor(.deepSprout)
                Text("\(viewModel.storeDetail?.welcomeOpen ?? "") - \(viewModel.closeTime)")
                    .pretendardFont(size: .body2)
                    .foregroundColor(.gray60)
                Spacer()
            }
            .padding(.horizontal,8)
            
            HStack(alignment: .top) {
                Text("주차여부")
                    .pretendardFont(size: .body2)
                    .foregroundColor(.gray60)
                    .padding(.trailing, 8)
                
                Image(systemName: "car.fill")
                    .foregroundColor(.deepSprout)
                Text(viewModel.storeDetail?.parkingGuide ?? "주차 정보 없음")
                    .lineLimit(3)
                    .pretendardFont(size: .body2)
                    .foregroundColor(.gray60)
            }
            .padding(.horizontal,8)
            .padding(.bottom, 4)
        }
        .padding(10)
        .cornerRadius(15)
        .background(.gray0)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(.gray60, lineWidth: 1)
        )
    }
    
    // MARK: - 예상 소요시간 섹션
    private var estimatedTimeSection: some View {
        HStack {
            Image(systemName: "clock")
                .foregroundColor(.deepSprout)
            Text("예상 소요시간 ")
                .pretendardFont(size: .body2)
                .foregroundColor(.deepSprout)
            
            Text("\(viewModel.storeDetail?.estimatedPickupTime ?? 0)분")
                .pretendardFont(size: .body2, weight: .bold)
                .foregroundColor(.deepSprout)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .cornerRadius(15)
        .background(.gray0)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(.gray60, lineWidth: 1)
        )
    }
    
    // MARK: - 메뉴 섹션
    private var menuSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 메뉴 필터
            menuFilterSection
            // 메뉴 목록
            menuListSection
                .padding(.horizontal)
        }
    }
    
    // MARK: - 메뉴 필터
    private var menuFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(menuCategories, id: \.self) { category in
                    Button(action: {
                        selectedMenuCategory = category
                    }) {
                        Text(category)
                            .pretendardFont(size: .body3, weight: .medium)
                            .foregroundColor(selectedMenuCategory == category ? .white : .blackSprout)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedMenuCategory == category ? .blackSprout : .gray0)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.blackSprout, lineWidth: 1)
                            )
                            .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - 메뉴 목록
    private var menuListSection: some View {
        LazyVStack(spacing: 16) {
            ForEach(filteredMenus, id: \.menuID) { menu in
                MenuItemView(viewModel: diContainer.getMenuItemViewModel(menu: menu))
                Divider()
            }
        }
    }
    
    // MARK: - 계산된 속성들
    private var menuCategories: [String] {
        var categories = ["전체"]
        let menuCategories = viewModel.storeDetail?.menuList.map { $0.category } ?? []
        categories.append(contentsOf: Array(Set(menuCategories)))
        return categories
    }
    
    private var filteredMenus: [MenuList] {
        guard let menus = viewModel.storeDetail?.menuList else { return [] }
        
        if selectedMenuCategory == "전체" {
            return menus
        } else {
            return menus.filter { $0.category == selectedMenuCategory }
        }
    }
}

