//
//  ContentView.swift
//  GaGaISo
//
//  Created by marty.academy on 5/13/25.
//

import SwiftUI
import Combine
import SwiftUI

struct ContentView: View {
    @Environment(\.diContainer) private var diContainer
    @EnvironmentObject private var navigationManager: AppNavigationManager
    
    @State private var testtab : AppTab = .home
    
    var body: some View {
        TabView(selection:$navigationManager.selectedTab) {
            NavigationStack(path: $navigationManager.homeNavigationPath) {
                HomeView(viewModel: diContainer.getHomeViewModel())
                    .navigationDestination(for: AppDestination.self) { destination in
                        destinationView(for: destination)
                    }
            }
            .tabItem {
                Label(AppTab.home.title, systemImage: AppTab.home.icon)
            }
            .tag(AppTab.home)
            
            NavigationStack(path: $navigationManager.ordersNavigationPath) {
                OrdersView()
                    .navigationDestination(for: AppDestination.self) { destination in
                        destinationView(for: destination)
                    }
            }
            .tabItem {
                Label(AppTab.orders.title, systemImage: AppTab.orders.icon)
            }
            .tag(AppTab.orders)
            
            NavigationStack(path: $navigationManager.communityNavigationPath) {
                CommunityView(viewModel: diContainer.getCommunityViewModel())
                    .navigationDestination(for: AppDestination.self) { destination in
                        destinationView(for: destination)
                    }
            }
            .tabItem {
                Label(AppTab.community.title, systemImage: AppTab.community.icon)
            }
            .tag(AppTab.community)
            
            NavigationStack(path: $navigationManager.profileNavigationPath ) {
                ProfileView()
                    .navigationDestination(for: AppDestination.self) { destination in
                        destinationView(for: destination)
                    }
            }
            .tabItem {
                Label(AppTab.profile.title, systemImage: AppTab.profile.icon)
            }
            .tag(AppTab.profile)
        }
        .onAppear {
            setupTabBarAppearance()
        }
    }
    
    @ViewBuilder
    private func destinationView(for destination: AppDestination) -> some View {
        switch destination {
        case .storeDetail(let storeId):
            StoreDetailView(
                viewModel: diContainer.getStoreDetailViewModel(storeId: storeId)
            )
        case .orderStatus(let orderId):
            OrdersView()
        case .memuDetail(let menu):
            MenuDetailView(viewModel: diContainer.getMenuDetailViewModel(menu: menu))
        default:
            EmptyView()
        }
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.blackSprout)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color.blackSprout)
        ]
        
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.gray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.gray
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
