//
//  CommunityRouter.swift
//
//
//  Created by marty.academy on 5/11/25.
//

import Foundation

enum CommunityOrderCriteria: String {
    case createdAt
    case likes
}

enum CommunityRouter: RouterProtocol {
    case v1PostFiles(files: [String])
    case v1Posts(category: String, title: String, content: String, storeId: String, latitude: Double, longitude: Double, file: [String])
    case v1GetPost(category: String, latitude: Double, longitude: Double, maxDistance: String, limit: Int, next: String, orderBy: CommunityOrderCriteria)
    case v1SearchPost(title: String)
    case v1GetPostDetail(postId: String)
    case v1ModifyPost(postId: String, category: String, title: String, content: String, storeId: String, latitude: Double, longitude: Double, file: [String])
    case v1DeletePost(postId: String)
    case v1LikePost(postId: String, status: Bool)
    case v1GetPostBasedOn(userId: String, category: String, limit: Int, next: String)
    case v1GetPostLikedByMe(category: String, next: String, limit: Int)

    var baseURL: URL {
        guard let url = URL(string: ExternalDatasource.pickup.baseURLString) else {
            fatalError("[Error: Router] Couldn't find baseURL error")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .v1PostFiles: return "v1/posts/files"
        case .v1Posts: return "v1/posts"
        case .v1GetPost: return "v1/posts/geolocation"
        case .v1SearchPost: return "v1/posts/search"
        case .v1GetPostDetail(let postId) : return "v1/posts/\(postId)"
        case .v1ModifyPost(let postId, _, _, _, _, _, _,_) : return "v1/posts/\(postId)"
        case .v1DeletePost(let postId) : return "v1/posts/\(postId)"
        case .v1LikePost(let postId, _) : return "v1/posts/\(postId)/like"
        case .v1GetPostBasedOn(let userId, _, _, _)  : return "v1/posts/users/\(userId)"
        case .v1GetPostLikedByMe: return "v1/posts/likes/me"
        }
    }
    
    var parameter : [URLQueryItem] {
        switch self {
        case .v1GetPost(let category, let latitude, let longitude,let maxDistance,let limit, let next, let orderBy):
            return [
                .init(name: "category", value: category),
                .init(name: "latitude", value: "\(latitude)"),
                .init(name: "longitude", value: "\(longitude)"),
                .init(name: "maxDistance", value: maxDistance),
                .init(name: "next", value: next),
                .init(name: "orderBy", value: orderBy.rawValue)
            ]
        case .v1SearchPost(let title):
            return [
                .init(name: "title", value: title)
            ]
        case .v1GetPostBasedOn(_, let category, let limit, let next), .v1GetPostLikedByMe(let category, let next, let limit):
            return [
                .init(name: "category", value: category),
                .init(name: "next", value: next),
                .init(name: "limit", value: "\(limit)"),
            ]
        default: return []
        }
    }
    
    var body: Data? {
        switch self {
        case .v1PostFiles:
            return nil
            
        case .v1Posts(let category, let title, let content, let storeId, let latitude, let longitude, let files):
            let dict = [
                "category": category,
                "title": title,
                "content": content,
                "store_id": storeId,
                "latitude": latitude,
                "longitude": longitude,
                "files": files
            ] as [String : Any]
            return try? JSONSerialization.data(withJSONObject: dict)
            
        case .v1ModifyPost(let postId, let category, let title, let content, let storeId, let latitude, let longitude, let files):
            let dict = [
                "category": category,
                "title": title,
                "content": content,
                "store_id": storeId,
                "latitude": latitude,
                "longitude": longitude,
                "files": files
            ] as [String : Any]
            return try? JSONSerialization.data(withJSONObject: dict)
            
        case .v1LikePost(_, let isLike):
            let dict = [
                "like_status": isLike
            ] as [String: Any]
            return try? JSONSerialization.data(withJSONObject: dict)
            
        default: return nil
        }
    }
    
    var method: String {
        switch self {
        case .v1PostFiles, .v1Posts, .v1LikePost:
            return "POST"
        case .v1DeletePost:
            return "DELETE"
        case .v1ModifyPost:
            return "PUT"
        default: return "GET"
        }
    }
}
