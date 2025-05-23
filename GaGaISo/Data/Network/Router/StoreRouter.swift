//
//  StoreRouter.swift
//
//
//  Created by marty.academy on 5/11/25.
//

import Foundation

enum StoreRouterSortingCriteria: String {
    case distance = "distance"
    case orders = "orders"
    case reviews = "reviews"
}

enum StoreRouter: RouterProtocol {
    case v1LocationBasedStore(category: String, longitude: Double, latitude: Double, next: String, limit: Int, orderBy: StoreRouterSortingCriteria)
    case v1StoreDetailInfo(storeId: String)
    case v1ExecuteStoreLike(storeId: String, status: Bool)
    case v1SearchStore(name: String)
    case v1GetPopularStore(category: String)
    case v1GetPopularSearchKeyword
    case v1GetLikedStore(category: String, next: String, limit: Int)
    
    var baseURL: URL {
        guard let url = URL(string: ExternalDatasource.pickup.baseURLString) else {
            fatalError("[Error: Router] Couldn't find baseURL error")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .v1LocationBasedStore:
            return "v1/stores"
        case .v1StoreDetailInfo(let storeId):
            return "v1/stores/\(storeId)"
        case .v1ExecuteStoreLike(let storeId, _):
            return "v1/stores/\(storeId)/like"
        case .v1SearchStore:
            return "v1/stores/search"
        case .v1GetPopularStore:
            return "v1/stores/popular-stores"
        case .v1GetPopularSearchKeyword:
            return "v1/stores/searches-popular"
        case .v1GetLikedStore:
            return "v1/stores/likes/me"
        }
    }
    
    var parameter : [URLQueryItem] {
        switch self {
        case .v1LocationBasedStore(let category,let longitude,let latitude,let next,let limit, let orderBy):
            return [
                .init(name: "category", value: category),
                .init(name: "longitude", value: "\(longitude)"),
                .init(name: "latitude", value: "\(latitude)"),
                .init(name: "next", value: next),
                .init(name: "limit", value: "\(limit)"),
                .init(name: "order_by", value: orderBy.rawValue)
            ]
        case .v1SearchStore(let name) :
            return [
                .init(name: "name", value: name)
            ]
        case .v1GetPopularStore(let category):
            return [
                .init(name: "category", value: category)
            ]
        case .v1GetLikedStore(let category, let next, let limit) :
            return [
                .init(name: "category", value: category),
                .init(name: "next", value: next),
                .init(name: "limit", value: "\(limit)")
            ]
            
        default: return []
        }
    }
    var body: Data? {
        switch self {
        case .v1ExecuteStoreLike( _, let status):
            let dict = [
                "like_status": status
            ]
            return try? JSONSerialization.data(withJSONObject: dict)
            
        default: return nil
        }
    }
    
    var method: String {
        switch self {
        case .v1ExecuteStoreLike: return "POST"
        default: return "GET"
        }
    }
}
