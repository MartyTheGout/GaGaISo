////
////  StoreCardListView.swift
////  GaGaISo
////
////  Created by marty.academy on 5/21/25.
////
import SwiftUI

struct StoreListView: View {
    var store: NearbyStoresDTO
    
    var body: some View {
        VStack(spacing: 15) {
            ForEach(store.data, id: \.storeID) { store in
                StoreCard(store: store)
            }
        }
        .padding(.horizontal)
    }
}
