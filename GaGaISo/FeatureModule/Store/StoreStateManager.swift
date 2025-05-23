//
//  StoreStateManager.swift
//  GaGaISo
//
//  Created by marty.academy on 5/23/25.
//

import Foundation
import Combine

class StoreStateManager: ObservableObject {
    @Published private(set) var stores: [String: StoreDTO] = [:]
    
    private let storeService: StoreService
    private var cancellables = Set<AnyCancellable>()
    
    init(storeService: StoreService) {
        self.storeService = storeService
    }
    
    func updateStores(_ newStores: [StoreDTO]) {
        for store in newStores {
            stores[store.storeID] = store
        }
    }
    
    // optimistic update approach
    func toggleLike(for storeId: String) async {
        guard var store = stores[storeId] else { return }
        
        store.isPick.toggle()
        stores[storeId] = store
        
        let result = await storeService.updateStoreLike(
            storeId: storeId,
            isLiked: store.isPick
        )
        
        switch result {
        case .success(let actualLikeStatus):
            if actualLikeStatus != store.isPick {
                store.isPick = actualLikeStatus
                stores[storeId] = store
            }
        case .failure:
            store.isPick.toggle()
            stores[storeId] = store
        }
    }
    
    func store(for id: String) -> StoreDTO? {
        stores[id]
    }
}
