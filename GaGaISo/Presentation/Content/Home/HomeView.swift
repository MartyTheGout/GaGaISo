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
                
                // Food categories and listings would go here
                // Similar to the first screenshot
            }
        }
    }
}
