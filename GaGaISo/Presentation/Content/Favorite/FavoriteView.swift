//
//  FavoriteView.swift
//  GaGaISo
//
//  Created by marty.academy on 5/19/25.
//

import SwiftUI
import ComposableArchitecture

struct FavoritesView: View {
    let store: StoreOf<FavoritesFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Text("Favorites")
                .font(.largeTitle)
        }
    }
}
