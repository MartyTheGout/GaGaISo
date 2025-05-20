//
//  ContentFeature.swift
//  GaGaISo
//
//  Created by marty.academy on 5/17/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ContentFeature {
    enum Tab: Equatable {
           case home
           case orders
           case favorites
           case profile
       }
        
    struct State: Equatable {
        var selectedTab: Tab = .home
        var home  = HomeFeature.State()
        var orders = OrdersFeature.State()
        var favorites = FavoritesFeature.State()
        var profile = ProfileFeature.State()
    }
    
    enum Action: Equatable {
        case tabSelected(Tab)
        case home(HomeFeature.Action)
        case orders(OrdersFeature.Action)
        case favorites(FavoritesFeature.Action)
        case profile(ProfileFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none
                
            case .home, .orders, .favorites, .profile:
                return .none
            }
        }
        
        Scope(state: \.home, action: \.home) {
            HomeFeature()
        }
        
        Scope(state: \.orders, action: \.orders) {
            OrdersFeature()
        }
        
        Scope(state: \.favorites, action: \.favorites) {
            FavoritesFeature()
        }
        
        Scope(state: \.profile, action: \.profile) {
            ProfileFeature()
        }
    }
}
