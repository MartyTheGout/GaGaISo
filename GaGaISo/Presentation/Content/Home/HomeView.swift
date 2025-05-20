//
//  HomeView.swift
//  GaGaISo
//
//  Created by marty.academy on 5/19/25.
//

import SwiftUI
import ComposableArchitecture

struct HomeView: View {
    let store: StoreOf<HomeFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                Text("Home")
                    .font(.largeTitle)
                    .padding()
                
                LocationRevealingView(store: store.scope(state: \.locationState, action: \.locationAction))
                
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal)
        }
    }
}
