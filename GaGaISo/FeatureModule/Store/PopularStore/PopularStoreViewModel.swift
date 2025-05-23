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
    private var storeService: StoreService
    private let storeContext: StoreContext
    private var cancellables = Set<AnyCancellable>()
    
    @Published var categories: [CategoryItem] = [
        CategoryItem(icon: "coffee", title: "커피", isSelected: false),
        CategoryItem(icon: "fastfood", title: "패스트푸드", isSelected: false),
        CategoryItem(icon: "desert", title: "디저트", isSelected: true),
        CategoryItem(icon: "bakery", title: "베이커리", isSelected: false),
        CategoryItem(icon: "etc", title: "more", isSelected: false)
    ]
    
    @Published var storeIds: [String] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    init(storeService: StoreService, storeContext: StoreContext) {
        self.storeService = storeService
        self.storeContext = storeContext
        storeContext.$stores
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
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
    
    func loadPopularStores() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        let result = await storeService.getTrendingStores("")
        
        await MainActor.run {
            switch result {
            case .success(let stores):
                self.storeContext.updateStores(stores)
                self.storeIds = stores.map { $0.storeID }
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
            
            self.isLoading = false
        }
    }
    
    private func loadStoresByCategory(_ category: String) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        let result = await storeService.getTrendingStores(selectedCategory!.title)
        
        await MainActor.run {
            switch result {
            case .success(let stores):
                self.storeContext.updateStores(stores)
                self.storeIds = stores.map { $0.storeID }
            case .failure(let error):
                self.errorMessage =  error.localizedDescription
            }
            self.isLoading = false
        }
    }

    func refreshData() async {
        await loadStoresByCategory(selectedCategory!.title)
    }
}
