//
//  HomeView.swift
//  GaGaISo
//
//  Created by marty.academy on 5/19/25.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.diContainer) private var diContainer
    @StateObject private var viewModel: HomeViewModel
    
    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            VStack {
                LocationRevealingView(viewModel: diContainer.getLocationViewModel())
                    .padding(.vertical)
                
                SearchBarView()
                
                PopularKeywordView(viewModel: diContainer.getPopularKeywordViewModel())
                
                VStack {
                    PopularStoreView(viewModel: diContainer.getPoupularStoreViewModel())
                        .padding(.top)
                    
                    AdView(imageURL: "")
                    
                    FavoriteStoresSection(currentTab: $viewModel.currentTab)
                        .padding(.vertical)
                    
                    if let store = viewModel.stores {
                        StoreListView(store: store)
                    }
                }
                .frame(maxWidth: .infinity)
                .background(.gray0)
                .cornerRadius(25, corners: [.topLeft, .topRight])
            }
            
            .onAppear {
                Task {
                    await viewModel.onAppear()
                }
            }
            .onDisappear {
                viewModel.onDisappear()
            }
        }
        .background(Color.brightSprout.ignoresSafeArea())
    }
}

#Preview {
    let diContainer = DIContainer()
    HomeView(viewModel: diContainer.getHomeViewModel())
}
