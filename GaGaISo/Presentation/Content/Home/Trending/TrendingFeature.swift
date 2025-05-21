//
//  TrendingFeature.swift
//  GaGaISo
//
//  Created by marty.academy on 5/21/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct TrendingStoreFeature {
    struct State: Equatable, Identifiable {
        let id: UUID
        let name: String
        let imageName: String
        let likes: Int
        let distance: Double
        let closeTime: String
        let visitCount: Int
        var isFavorite: Bool
    }
    
    enum Action: Equatable {
        case favoriteButtonTapped
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .favoriteButtonTapped:
                state.isFavorite.toggle()
                return .none
            }
        }
    }
}
