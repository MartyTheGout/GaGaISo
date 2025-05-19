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
    struct State: Equatable {
        var selectedTab: Tab = .home
        var home: HomeFeature.State = .init()
        var orders: OrdersFeature.State = .init()
        var favorites: FavoritesFeature.State = .init()
        var profile: ProfileFeature.State = .init()
        var isMiddleButtonActive: Bool = false
    }
    
    enum Action: Equatable {
        case tabSelected(Tab)
        case middleButtonTapped
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
                
            case .middleButtonTapped:
                state.isMiddleButtonActive.toggle()
                return .none
                
            case .home, .orders, .favorites, .profile:
                return .none
            }
        }
        
        Scope(state: \.home, action: /Action.home) {
            HomeFeature()
        }
        
        Scope(state: \.orders, action: /Action.orders) {
            OrdersFeature()
        }
        
        Scope(state: \.favorites, action: /Action.favorites) {
            FavoritesFeature()
        }
        
        Scope(state: \.profile, action: /Action.profile) {
            ProfileFeature()
        }
    }
}
