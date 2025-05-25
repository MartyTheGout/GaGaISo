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
    
    func getPopularKeyword() async -> Result<[String], Error> {
        let result = await networkManager.request(StoreRouter.v1GetPopularSearchKeyword, type: PopularKeywordDTO.self)
        return result.map { $0.data }.mapError { $0 as Error }
    }
    
    func getTrendingStores(_ category: String) async -> Result<[StoreDTO], Error> {
        let result = await networkManager.request(StoreRouter.v1GetPopularStore(category: category), type: TrendingStoresDTO.self)
        return result.map { $0.data }.mapError { $0 as Error }
    }
    
    func updateStoreLike(storeId: String, isLiked: Bool) async -> Result<Bool, Error> {
        let result = await networkManager.request(StoreRouter.v1ExecuteStoreLike(storeId: storeId, status: isLiked), type: LikeStatusDTO.self)
        return result.map { $0.likeStatus }.mapError { $0 as Error }
    }
    
    func getStoresNearBy(category: String, latitude: Double, longitude: Double, next : String, orderby: StoreRouterSortingCriteria) async -> Result<[StoreDTO], Error> {
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
        
        return result.map { $0.data }.mapError { $0 as Error }
    }
    
    func getLikedStores(category: String = "", next : String = "") async -> Result<[StoreDTO], Error> {
        let result = await networkManager.request(
            StoreRouter.v1GetLikedStore(category: category, next: next, limit: 10),
            type: NearbyStoresDTO.self
        )
        return result.map { $0.data }.mapError { $0 as Error }
    }
}
