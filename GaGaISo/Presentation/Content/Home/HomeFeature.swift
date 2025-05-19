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
    struct State: Equatable {}
    enum Action: Equatable {}
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            return .none
        }
    }
}
