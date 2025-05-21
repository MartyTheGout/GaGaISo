//
//  StoreManager.swift
//  GaGaISo
//
//  Created by marty.academy on 5/21/25.
//

import Foundation

// Model
struct Store: Decodable, Identifiable, Equatable {
    let id: UUID
    let name: String
    let imageName: String
    let rating: Double
    let reviewCount: Int
    let likes: Int
    let distance: Double
    let closeTime: String
    let visitCount: Int
    let tags: [String]
    let isFavorite: Bool
}

// Protocol
protocol StoreManagerProtocol {
    func fetchStores(category: Int) async throws -> [StoreItemFeature.State]
}

// Implementation
struct StoreManager: StoreManagerProtocol {
    func fetchStores(category: Int) async throws -> [StoreItemFeature.State] {

        // 카테고리에 따라 다른 데이터 반환
        switch category {
        case 0: // 커피
            return [
                .init(id: UUID(), name: "새싹 커피하우스", imageName: "coffee", rating: 4.7, reviewCount: 178, likes: 132, distance: 0.8, closeTime: "9PM", visitCount: 310, tags: ["#아메리카노", "#카페라떼"], isFavorite: false),
                .init(id: UUID(), name: "문래 카페", imageName: "coffee2", rating: 4.5, reviewCount: 156, likes: 112, distance: 1.2, closeTime: "10PM", visitCount: 240, tags: ["#브루잉", "#핸드드립"], isFavorite: false)
            ]
        case 1: // 패스트푸드
            return [
                .init(id: UUID(), name: "새싹 버거", imageName: "burger", rating: 4.3, reviewCount: 215, likes: 185, distance: 1.5, closeTime: "8PM", visitCount: 350, tags: ["#치즈버거", "#감자튀김"], isFavorite: false),
                .init(id: UUID(), name: "영등포 피자", imageName: "pizza", rating: 4.6, reviewCount: 192, likes: 165, distance: 2.1, closeTime: "9PM", visitCount: 270, tags: ["#페퍼로니", "#치즈크러스트"], isFavorite: false)
            ]
        case 2: // 디저트
            return [
                .init(id: UUID(), name: "새싹 마카롱 영등포직영점", imageName: "desert", rating: 4.9, reviewCount: 145, likes: 155, distance: 1.3, closeTime: "7PM", visitCount: 288, tags: ["#동카롱", "#티라미수"], isFavorite: false),
                .init(id: UUID(), name: "문래 새싹 티하우스", imageName: "tea", rating: 4.8, reviewCount: 211, likes: 202, distance: 2.0, closeTime: "6PM", visitCount: 197, tags: ["#일그레이 새싹티", "#꾸덕 말차 타르트"], isFavorite: false)
            ]
        default:
            return [
                .init(id: UUID(), name: "새싹 마카롱 영등포직영점", imageName: "desert", rating: 4.9, reviewCount: 145, likes: 155, distance: 1.3, closeTime: "7PM", visitCount: 288, tags: ["#동카롱", "#티라미수"], isFavorite: false),
                .init(id: UUID(), name: "문래 새싹 티하우스", imageName: "tea", rating: 4.8, reviewCount: 211, likes: 202, distance: 2.0, closeTime: "6PM", visitCount: 197, tags: ["#일그레이 새싹티", "#꾸덕 말차 타르트"], isFavorite: false)
            ]
        }
    }
}

// Mock Implementation
struct MockStoreManager: StoreManagerProtocol {
    func fetchStores(category: Int) async throws -> [StoreItemFeature.State] {
        return [
            .init(id: UUID(), name: "새싹 마카롱 영등포직영점", imageName: "desert", rating: 4.9, reviewCount: 145, likes: 155, distance: 1.3, closeTime: "7PM", visitCount: 288, tags: ["#동카롱", "#티라미수"], isFavorite: false),
            .init(id: UUID(), name: "문래 새싹 티하우스", imageName: "tea", rating: 4.8, reviewCount: 211, likes: 202, distance: 2.0, closeTime: "6PM", visitCount: 197, tags: ["#일그레이 새싹티", "#꾸덕 말차 타르트"], isFavorite: false)
        ]
    }
}

// Register Dependency
import Dependencies

extension DependencyValues {
    var storeManager: StoreManagerProtocol {
        get { self[StoreManagertKey.self] }
        set { self[StoreManagertKey.self] = newValue }
    }
}

private enum StoreManagertKey: DependencyKey {
    static let liveValue: StoreManagerProtocol = StoreManager()
    static let testValue: StoreManagerProtocol = MockStoreManager()
}
