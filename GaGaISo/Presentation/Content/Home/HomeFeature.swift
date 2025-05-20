//
//  HomeFeature.swift
//  GaGaISo
//
//  Created by marty.academy on 5/19/25.
//

import ComposableArchitecture
import Foundation

@Reducer
struct HomeFeature {
    struct State: Equatable {
        var locationState = LocationRevealingFeature.State()
    }
    
    enum Action: Equatable {
        case locationAction(LocationRevealingFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .locationAction : return .none
            }
        }
        
        Scope(state: \.locationState, action: \.locationAction) {
            LocationRevealingFeature()
        }
    }
}
