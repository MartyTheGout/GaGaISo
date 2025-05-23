//
//  TrendingStoreCardViewModel.swift
//  GaGaISo
//
//  Created by marty.academy on 5/23/25.
//

import Foundation
import SwiftUI
import Combine

class TrendingStoreCardViewModel: ObservableObject {
    
    let storeId: String
    
    private let storeStateManager: StoreStateManager
    private let imageService: ImageService
    private var cancellables = Set<AnyCancellable>()
    
    @Published var storeImage: UIImage?
    @Published var isImageLoading: Bool = false
    @Published var imageLoadError: String?
    
    var store: StoreDTO? {
        storeStateManager.store(for: storeId)
    }
    
    init(storeId: String, storeStateManager: StoreStateManager, imageService: ImageService) {
        self.storeId = storeId
        self.storeStateManager = storeStateManager
        self.imageService = imageService
        
        storeStateManager.$stores
            .map { $0[storeId] }
            .removeDuplicates(by: { oldStore, newStore in // or Make StoreDTO Equtable
                oldStore?.storeID == newStore?.storeID &&
                oldStore?.isPick == newStore?.isPick &&
                oldStore?.name == newStore?.name
            })
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    func loadStoreImage() {
        guard let store, !store.storeImageUrls.isEmpty else { return }
        
        let imageUrl = store.storeImageUrls[0]
        loadImage(from: imageUrl)
    }
    
    private func loadImage(from urlString: String) {
        isImageLoading = true
        imageLoadError = nil
        
        Task {
            let result = await imageService.fetchImageWith(urlString: urlString)
            
            await MainActor.run {
                switch result {
                case .success(let image):
                    self.storeImage = image
                case .failure(let error):
                    self.imageLoadError = error.localizedDescription
                }
                self.isImageLoading = false
            }
        }
    }
    
    func toggleLike() {
        Task {
            await storeStateManager.toggleLike(for: storeId)
        }
    }
}

extension TrendingStoreCardViewModel {
    var hasStore: Bool {
        storeStateManager.store(for: storeId) != nil
    }
    
    var name: String {
        storeStateManager.store(for: storeId)?.name ?? "로딩 중..."
    }
    
    var isPick: Bool {
        storeStateManager.store(for: storeId)?.isPick ?? false
    }
    
    var isPicchelin: Bool {
        storeStateManager.store(for: storeId)?.isPicchelin ?? false
    }
    
    var distance: String {
        if let distance = storeStateManager.store(for: storeId)?.distance {
            return String(format: "%.1f", distance)
        }
        return "---"
    }
    
    var closeTime: String {
        storeStateManager.store(for: storeId)?.close ?? "--:--"
    }
    
    var pickCount: String {
        if let count = storeStateManager.store(for: storeId)?.pickCount {
            return "\(count)회"
        }
        return "0회"
    }
    
    var totalReviewCount: String {
        if let count = storeStateManager.store(for: storeId)?.totalReviewCount {
            return "\(count)개"
        }
        return "0개"
    }
    
    var storeImageUrls: [String] {
        storeStateManager.store(for: storeId)?.storeImageUrls ?? []
    }
}
