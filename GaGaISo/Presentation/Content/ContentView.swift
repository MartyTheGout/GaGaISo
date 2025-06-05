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
    private let navigationManager = AppNavigationManager.shared
    
    @State private var selectedTab: AppTab = .home
    @State private var homeNavigationPath = NavigationPath()
    @State private var ordersNavigationPath = NavigationPath()
    @State private var profileNavigationPath = NavigationPath()
    @State private var communityNavigationPath = NavigationPath()
    
    var body: some View {
        TabView(selection:$selectedTab) {
            NavigationStack(path: $homeNavigationPath) {
                HomeView(viewModel: diContainer.getHomeViewModel())
                    .navigationDestination(for: AppDestination.self) { destination in
                        destinationView(for: destination)
                    }
            }
            .tabItem {
                Label(AppTab.home.title, systemImage: AppTab.home.icon)
            }
            .tag(AppTab.home)
            
            NavigationStack(path: $ordersNavigationPath) {
                OrdersView()
                    .navigationDestination(for: AppDestination.self) { destination in
                        destinationView(for: destination)
                    }
            }
            .tabItem {
                Label(AppTab.orders.title, systemImage: AppTab.orders.icon)
            }
            .tag(AppTab.orders)
            
            NavigationStack(path: $communityNavigationPath) {
                CommunityView(viewModel: diContainer.getCommunityViewModel())
                    .navigationDestination(for: AppDestination.self) { destination in
                        destinationView(for: destination)
                    }
            }
            .tabItem {
                Label(AppTab.community.title, systemImage: AppTab.community.icon)
            }
            .tag(AppTab.community)
            
            NavigationStack(path: $profileNavigationPath ) {
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
        .onReceive(navigationManager.$selectedTab) { newTab in
            selectedTab = newTab
        }
        .onReceive(navigationManager.$homeNavigationPath) { newPath in
            homeNavigationPath = newPath
        }
        .onReceive(navigationManager.$ordersNavigationPath) { newPath in
            ordersNavigationPath = newPath
        }
        .onReceive(navigationManager.$communityNavigationPath) { newPath in
            communityNavigationPath = newPath
        }
        .onReceive(navigationManager.$profileNavigationPath) { newPath in
            profileNavigationPath = newPath
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
