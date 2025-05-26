//
//  PopularStoreView.swift
//  GaGaISo
//
//  Created by marty.academy on 5/22/25.
//

import SwiftUI

struct PopularStoreView: View {
    @Environment(\.diContainer) private var diContainer
    @StateObject private var navigationManager = AppNavigationManager.shared
    
    @StateObject private var viewModel: PopularStoreViewModel
    
    init(viewModel: PopularStoreViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 20) {
                ForEach(viewModel.categories) { category in
                    CategoryItemView(
                        category: category,
                        onTap: {
                            viewModel.selectCategory(category)
                        }
                    )
                }
            }
            .padding(.horizontal)
            
            HStack {
                Text("실시간 가가이소 맛집")
                    .pretendardFont(size: .body2, weight: .bold)
                    .foregroundStyle(.gray90)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)
            
            if viewModel.isLoading {
                ProgressView("로딩 중...")
                    .frame(height: 200)
            } else if !viewModel.storeIds.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(viewModel.storeIds, id: \.self) { storeId in
                            Button(action: {
                                navigationManager.navigate(to: .storeDetail(storeId: storeId))
                            }) {
                                TrendingStoreCard(
                                    viewModel: diContainer.getTrendingStoreCardViewModel(storeId: storeId)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            } else {
                VStack {
                    Text("스토어 정보를 불러올 수 없습니다")
                        .foregroundColor(.gray)
                    
                    Button("다시 시도") {
                        Task {
                            await viewModel.refreshData()
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .frame(height: 200)
            }
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }
        }
        .onAppear {
            Task {
                await viewModel.loadPopularStores()
            }
        }
    }
}
