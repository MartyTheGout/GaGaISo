//
//  ContentView.swift
//  GaGaISo
//
//  Created by marty.academy on 5/13/25.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    let store: StoreOf<ContentFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            TabView(selection: viewStore.binding(
                get: \.selectedTab,
                send: ContentFeature.Action.tabSelected
            )) {
                HomeView(
                    store: store.scope(
                        state: \.home,
                        action: \.home
                    )
                )
                .tabItem {
                    Label("홈", systemImage: "house.fill")
                }
                .tag(ContentFeature.Tab.home)
                
                OrdersView(
                    store: store.scope(
                        state: \.orders,
                        action: \.orders
                    )
                )
                .tabItem {
                    Label("주문", systemImage: "list.bullet")
                }
                .tag(ContentFeature.Tab.orders)
                
                FavoritesView(
                    store: store.scope(
                        state: \.favorites,
                        action: \.favorites
                    )
                )
                .tabItem {
                    Label("즐겨찾기", systemImage: "heart.fill")
                }
                .tag(ContentFeature.Tab.favorites)
                
                ProfileView(
                    store: store.scope(
                        state: \.profile,
                        action: \.profile
                    )
                )
                .tabItem {
                    Label("프로필", systemImage: "person.fill")
                }
                .tag(ContentFeature.Tab.profile)
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
}
