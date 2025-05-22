//
//  StoreItemFeature.swift
//  GaGaISo
//
//  Created by marty.academy on 5/21/25.
//

import Foundation
import Combine

class StoreItemViewModel: ObservableObject, Identifiable {
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
    
    @Published var isFavorite: Bool
    
    // 의존성
    private let favoriteService: FavoriteServiceProtocol?
    private var cancellables = Set<AnyCancellable>()
    
    init(
        id: UUID,
        name: String,
        imageName: String,
        rating: Double,
        reviewCount: Int,
        likes: Int,
        distance: Double,
        closeTime: String,
        visitCount: Int,
        tags: [String],
        isFavorite: Bool,
        favoriteService: FavoriteServiceProtocol? = nil
    ) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.rating = rating
        self.reviewCount = reviewCount
        self.likes = likes
        self.distance = distance
        self.closeTime = closeTime
        self.visitCount = visitCount
        self.tags = tags
        self.isFavorite = isFavorite
        self.favoriteService = favoriteService
    }
    
    func toggleFavorite() {
        isFavorite.toggle()
        
        // 서비스를 통한 백엔드 업데이트 (선택 사항)
        if let service = favoriteService {
            Task {
                do {
                    try await service.toggleFavorite(storeId: id.uuidString, status: isFavorite)
                } catch {
                    print("즐겨찾기 업데이트 실패: \(error)")
                    // 실패 시 롤백
                    await MainActor.run {
                        self.isFavorite.toggle()
                    }
                }
            }
        }
    }
}

// 즐겨찾기 서비스 프로토콜 (실제 구현은 DIContainer에서 주입)
protocol FavoriteServiceProtocol {
    func toggleFavorite(storeId: String, status: Bool) async throws
}
