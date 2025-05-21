////
////  StoreCardListView.swift
////  GaGaISo
////
////  Created by marty.academy on 5/21/25.
////
//
//import ComposableArchitecture
//import SwiftUI
//
//struct StoreListView: View {
//    let stores: IdentifiedArrayOf<StoreItemFeature.State>
//    let onStoreAction: (UUID, StoreItemFeature.Action) -> Void
//    
//    var body: some View {
//        VStack(spacing: 15) {
//            ForEach(stores) { storeState in
//                
//                StoreCard(
//                    store: Store(initialState: storeState) {
//                        StoreItemFeature()
//                    }
//                    //Store<StoreItemFeature.State, StoreItemFeature.Action> == StoreOf<StoreItemFeature>
//                )
//            }
//        }
//        .padding(.horizontal)
//    }
//}
//
