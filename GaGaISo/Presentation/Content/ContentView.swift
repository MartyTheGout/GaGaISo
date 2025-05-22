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
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            HomeView(viewModel: diContainer.getHomeViewModel())
                .tabItem {
                    Label("홈", systemImage: "house.fill")
                }
                .tag(Tab.home)
            
            OrdersView()
                .tabItem {
                    Label("주문", systemImage: "list.bullet")
                }
                .tag(Tab.orders)
            
            FavoritesView()
                .tabItem {
                    Label("즐겨찾기", systemImage: "heart.fill")
                }
                .tag(Tab.favorites)
            
            ProfileView()
                .tabItem {
                    Label("프로필", systemImage: "person.fill")
                }
                .tag(Tab.profile)
        }
        .onAppear {
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
}
