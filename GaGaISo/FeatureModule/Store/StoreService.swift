//
//  StoreManager.swift
//  GaGaISo
//
//  Created by marty.academy on 5/21/25.
//

import Foundation

class StoreService {
    private var networkManager: StrategicNetworkHandler
    
    init(networkManager: StrategicNetworkHandler) {
        self.networkManager = networkManager
    }
    
    func getPopularKeyword() async -> Result<[String], APIError> {
        let result = await networkManager.request(StoreRouter.v1GetPopularSearchKeyword, type: PopularKeywordDTO.self)
        return result.map { $0.data }
    }
    
    func getTrendingStores(_ category: String) async -> Result<[StoreDTO], APIError> {
        let result = await networkManager.request(StoreRouter.v1GetPopularStore(category: category), type: TrendingStoresDTO.self)
        return result.map { $0.data }
    }
    
    func updateStoreLike(storeId: String, isLiked: Bool) async -> Result<Bool, APIError> {
        let result = await networkManager.request(StoreRouter.v1ExecuteStoreLike(storeId: storeId, status: isLiked), type: LikeStatusDTO.self)
        return result.map { $0.likeStatus }
    }
    
    func getStoresNearBy(category: String, latitude: Double, longitude: Double, next : String, orderby: StoreRouterSortingCriteria) async -> Result<[StoreDTO], APIError> {
        let result = await networkManager.request(
            StoreRouter.v1LocationBasedStore(
                category: category,
                longitude: longitude,
                latitude: latitude,
                next: next,
                limit: 5,
                orderBy: orderby
            ),
            type: NearbyStoresDTO.self
        )
        
        return result.map { $0.data }
    }
    
    func getLikedStores(category: String = "", next : String = "") async -> Result<[StoreDTO], APIError> {
        let result = await networkManager.request(
            StoreRouter.v1GetLikedStore(category: category, next: next, limit: 10),
            type: NearbyStoresDTO.self
        )
        return result.map { $0.data }
    }
    
    func getStoreDetail(storeId: String) async -> Result<StoreDetailDTO, APIError> {
        return  await networkManager.request(StoreRouter.v1StoreDetailInfo(storeId: storeId), type: StoreDetailDTO.self)
    }
}
