//
//  ContentView.swift
//  GaGaISo
//
//  Created by marty.academy on 5/13/25.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    let store : StoreOf<ContentFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack(alignment: .bottom) {
                TabView(selection: viewStore.binding(
                    get: \.selectedTab,
                    send: ContentFeature.Action.tabSelected
                )) {
                    HomeView(
                        store: store.scope(
                            state: \.home,
                            action: ContentFeature.Action.home
                        )
                    )
                    .tag(Tab.home)
                    
                    OrdersView(
                        store: store.scope(
                            state: \.orders,
                            action: ContentFeature.Action.orders
                        )
                    )
                    .tag(Tab.orders)
                    
                    FavoritesView(
                        store: store.scope(
                            state: \.favorites,
                            action: ContentFeature.Action.favorites
                        )
                    )
                    .tag(Tab.favorites)
                    
                    ProfileView(
                        store: store.scope(
                            state: \.profile,
                            action: ContentFeature.Action.profile
                        )
                    )
                    .tag(Tab.profile)
                }
                .ignoresSafeArea(edges: .bottom)
                
                CustomTabBar(
                    selectedTab: viewStore.binding(
                        get: \.selectedTab,
                        send: ContentFeature.Action.tabSelected
                    ),
                    isMiddleButtonActive: viewStore.binding(
                        get: \.isMiddleButtonActive,
                        send: { _ in ContentFeature.Action.middleButtonTapped }
                    )
                )
            }
        }
    }
}
