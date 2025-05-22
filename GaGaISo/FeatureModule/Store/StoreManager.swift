//
//  StoreManager.swift
//  GaGaISo
//
//  Created by marty.academy on 5/21/25.
//

import Foundation

class StoreManager : ObservableObject {
    
    private var networkManager: StrategicNetworkHandler
    
    init(networkManager: StrategicNetworkHandler) {
        self.networkManager = networkManager
    }
    
    //Error 로 고치기
    func getPopularKeyword() async -> [String]? {
        let result = await networkManager.request(StoreRouter.v1GetPopularSearchKeyword, type: PopularKeywordDTO.self)
        
        switch result {
        case .success(let normalResponse):
            let store = normalResponse.data
            return store
        case .failure(let error):
            return nil
        }
    }
    //Error 로 고치기
    func getTrendingStores(_ category: String) async -> [StoreDTO]? {
        let result = await networkManager.request(StoreRouter.v1GetPopularStore(category: category), type: TrendingStoresDTO.self)
        
        switch result {
        case .success(let normalResponse):
            let store = normalResponse.data
            return store
        case .failure(let error):
            return nil
        }
    }
    
    func updateStoreLike(storeId: String, isLiked: Bool) async -> Bool {
        // 실제 서버 like 처리 API 구현
        // 성공하면 true, 실패하면 false 반환
        return true
    }
}
