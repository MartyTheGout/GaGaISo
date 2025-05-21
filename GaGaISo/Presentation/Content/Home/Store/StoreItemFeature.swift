//
//  StoreItemFeature.swift
//  GaGaISo
//
//  Created by marty.academy on 5/21/25.
//
import ComposableArchitecture
import Foundation

@Reducer
struct StoreItemFeature {
    struct State: Equatable, Identifiable {
        let id: UUID
        let name: String
        let imageName: String
        let rating: Double
        let reviewCount: Int
        let likes: Int
        let distance: Double
        let closeTime: String
        let visitCount: Int
        let tags: [String]
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
