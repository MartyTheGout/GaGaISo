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
        
        WithViewStore(store, observe: {$0}) { viewStore in
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, world!")
            }
            .padding()
        }
    }
}
