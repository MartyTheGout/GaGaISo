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
        var items: [String] = []
        var isLoading = false
    }
    
    @CasePathable
    enum Action: Equatable {
        case onAppear
    }
    
    var body : some ReducerOf<Self>  {
        Reduce { state, action in
            switch action {
            case .onAppear : return .none
            }
        }
    }
}

