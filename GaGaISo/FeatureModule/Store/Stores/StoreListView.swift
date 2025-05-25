////
////  StoreCardListView.swift
////  GaGaISo
////
////  Created by marty.academy on 5/21/25.
////
import SwiftUI

struct StoreListView: View {
    @Environment(\.diContainer) private var diContainer
    @StateObject var viewModel : StoreListViewModel
    
    init(viewModel: StoreListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 15) {
            FavoriteStoresSection(currentTab: $viewModel.currentTab)
            
            ForEach(viewModel.storeIds, id: \.self) { storeId in
                StoreCard(viewModel: diContainer.getStoreItemViewModel(storeId: storeId))
                Divider().padding(4)
            }
        }
    }
}
