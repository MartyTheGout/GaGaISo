//
//  OrdersView.swift
//  GaGaISo
//
//  Created by marty.academy on 5/19/25.
//

import SwiftUI
import ComposableArchitecture

struct OrdersView: View {
    let store: StoreOf<OrdersFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Text("My Orders")
                .font(.largeTitle)
        }
    }
}
