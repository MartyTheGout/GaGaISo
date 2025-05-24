//
//  StoreContextManager.swift
//  GaGaISo
//
//  Created by marty.academy on 5/23/25.
//

import Foundation
import Combine

class StoreContext: ObservableObject {
    @Published private(set) var stores: [String: StoreDTO] = [:] {
        didSet {
            let changedStoreIds = Set(stores.keys).symmetricDifference(Set(oldValue.keys))
                .union(stores.compactMap { key, store in
                    oldValue[key]?.isPick != store.isPick ? key : nil
                })
            
            updateTimestampsForChangedStores(changedStoreIds)
        }
    }
    
    @Published var trendingStoreIds: [String] = [] {
        didSet {
            if trendingStoreIds != oldValue {
                trendingStoresLastUpdated = Date()
            }
        }
    }
    
    @Published var nearbyStoreIds: [String] = [] {
        didSet {
            if nearbyStoreIds != oldValue {
                nearbyStoresLastUpdated = Date()
            }
        }
    }
    
    @Published private(set) var trendingStoresLastUpdated = Date()
    @Published private(set) var nearbyStoresLastUpdated = Date()
    
    private let storeService: StoreService
    private var cancellables = Set<AnyCancellable>()
    
    init(storeService: StoreService) {
        self.storeService = storeService
    }
    
    func updateTrendingStores(_ newStores: [StoreDTO]) {
        for store in newStores {
            stores[store.storeID] = store
        }
        
        trendingStoreIds = newStores.map { $0.storeID }
        trendingStoresLastUpdated = Date()
    }
    
    func updateNearbyStores(_ newStores: [StoreDTO]) {
        for store in newStores {
            stores[store.storeID] = store
        }
        nearbyStoreIds = newStores.map { $0.storeID }
        nearbyStoresLastUpdated = Date()
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
            
            if trendingStoreIds.contains(storeId) {
                trendingStoresLastUpdated = Date()
            }
            if nearbyStoreIds.contains(storeId) {
                nearbyStoresLastUpdated = Date()
            }
            
        case .failure:
            store.isPick.toggle()
            stores[storeId] = store
        }
    }
    
    func store(for id: String) -> StoreDTO? {
        stores[id]
    }
    
    private func updateTimestampsForChangedStores(_ changedStoreIds: Set<String>) {
        let trendingSet = Set(trendingStoreIds)
        let nearbySet = Set(nearbyStoreIds)
        
        if !changedStoreIds.intersection(trendingSet).isEmpty {
            trendingStoresLastUpdated = Date()
        }
        
        if !changedStoreIds.intersection(nearbySet).isEmpty {
            nearbyStoresLastUpdated = Date()
        }
    }
}
