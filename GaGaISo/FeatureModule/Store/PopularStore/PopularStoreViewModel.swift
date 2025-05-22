//
//  PopularStoreViewModel.swift
//  GaGaISo
//
//  Created by marty.academy on 5/22/25.
//

import Foundation
import Combine
import SwiftUI

struct CategoryItem: Identifiable, Equatable {
    let id = UUID()
    let icon: String
    let title: String
    var isSelected: Bool
}

class PopularStoreViewModel: ObservableObject {
    
    private var storeManager: StoreManager
    private var cancellables = Set<AnyCancellable>()
    
    @Published var categories: [CategoryItem] = [
        CategoryItem(icon: "coffee", title: "커피", isSelected: false),
        CategoryItem(icon: "fastfood", title: "패스트푸드", isSelected: false),
        CategoryItem(icon: "desert", title: "디저트", isSelected: true),
        CategoryItem(icon: "bakery", title: "베이커리", isSelected: false),
        CategoryItem(icon: "etc", title: "more", isSelected: false)
    ]
    
    @Published var storeData: [StoreDTO]?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let likeActionSubject = PassthroughSubject<(storeId: String, likeStatus: Bool), Never>()
    
    init(storeManager: StoreManager) {
        self.storeManager = storeManager
        setupLikeDebounce()
    }
    
    func selectCategory(_ selectedCategory: CategoryItem) {
        categories = categories.map { category in
            CategoryItem(
                icon: category.icon,
                title: category.title,
                isSelected: category.title == selectedCategory.title
            )
        }
        
        Task {
            await loadStoresByCategory(selectedCategory.title)
        }
    }
    
    var selectedCategory: CategoryItem? {
        categories.first { $0.isSelected }
    }
    
    // MARK: - Data Loading
    func loadPopularStores() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
//        do {
            let stores = await storeManager.getTrendingStores("")
            
            await MainActor.run {
                self.storeData = stores
                self.isLoading = false
            }
//        } catch {
//            await MainActor.run {
//                self.errorMessage = error.localizedDescription
//                self.isLoading = false
//            }
//        }
    }
    
    private func loadStoresByCategory(_ category: String) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
//        do {
            let stores = await storeManager.getTrendingStores(selectedCategory!.title)
            
            await MainActor.run {
                self.storeData = stores
                self.isLoading = false
            }
//        } catch {
//            await MainActor.run {
//                self.errorMessage = error.localizedDescription
//                self.isLoading = false
//            }
//        }
    }
    
    // MARK: - Like Action with Debounce
    func executeLikeOn(storeId: String, likeStatus: Bool) {
        // Subject에 액션 전송 (debounce 처리됨)
        // 18번 연속 클릭하면 앞의 18번은 무시되고 마지막 1번만 실행
        likeActionSubject.send((storeId: storeId, likeStatus: likeStatus))
    }
    
    private func setupLikeDebounce() {
        likeActionSubject
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main) // 300ms 대기
            .removeDuplicates { previous, current in
                // 같은 storeId에 대한 중복 요청 제거
                previous.storeId == current.storeId && previous.likeStatus == current.likeStatus
            }
            .sink { [weak self] action in
                Task {
                    await self?.performLikeAction(
                        storeId: action.storeId,
                        likeStatus: action.likeStatus
                    )
                }
            }
            .store(in: &cancellables)
    }
    
    private func performLikeAction(storeId: String, likeStatus: Bool) async {
//        do {
            // 실제 네트워크 API 호출 (순수 서버 통신만)
            let success = await storeManager.updateStoreLike(
                storeId: storeId,
                isLiked: likeStatus
            )
            
            if !success {
                await MainActor.run {
                    errorMessage = "좋아요 처리 중 오류가 발생했습니다."
                }
            }
//        } catch {
//            await MainActor.run {
//                errorMessage = "네트워크 오류가 발생했습니다: \(error.localizedDescription)"
//            }
//        }
    }
    
    func getStoreById(_ storeId: String) -> StoreDTO? {
        storeData?.first { $0.storeID == storeId }
    }
    
    func refreshData() async {
        await loadStoresByCategory(selectedCategory!.title)
    }
    
    func clearError() {
        errorMessage = nil
    }
}
