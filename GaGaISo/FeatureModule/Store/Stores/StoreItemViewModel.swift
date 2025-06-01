//
//  StoreItemFeature.swift
//  GaGaISo
//
//  Created by marty.academy on 5/21/25.
//

import Foundation
import Combine
import SwiftUI

class StoreItemViewModel: ObservableObject {
    
    let storeId: String
    
    private let storeContext: StoreContext
    private let imageContext: ImageContext
    private var cancellables = Set<AnyCancellable>()
    
    @Published var storeImages: [UIImage] = []
    @Published var isImageLoading: Bool = false
    @Published var imageLoadError: String?
    
    var store: StoreDTO? {
        storeContext.store(for: storeId)
    }
    
    init(storeId: String, storeContext: StoreContext, imageContext: ImageContext) {
        self.storeId = storeId
        self.storeContext = storeContext
        self.imageContext = imageContext
        
        storeContext.$stores
            .map { $0[storeId] }
            .removeDuplicates(by: { oldStore, newStore in // isItToomuch?
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
        
        for imageUrl in store.storeImageUrls {
            loadImage(from: imageUrl)
        }
    }
    
    private func loadImage(from urlString: String) {
        isImageLoading = true
        imageLoadError = nil
        
        Task {
            let result = await imageContext.fetchImageWith(urlString: urlString)
            
            await MainActor.run {
                switch result {
                case .success(let image):
                    if let image {
                        self.storeImages.append(image)
                    }
                case .failure(let error):
                    self.imageLoadError = error.localizedDescription
                }
                self.isImageLoading = false
            }
        }
    }
    
    func toggleLike() {
        Task {
            await storeContext.toggleLike(for: storeId)
        }
    }
}

extension StoreItemViewModel {
    var hasStore: Bool {
        storeContext.store(for: storeId) != nil
    }
    
    var name: String {
        storeContext.store(for: storeId)?.name ?? "로딩 중..."
    }
    
    var isPick: Bool {
        storeContext.store(for: storeId)?.isPick ?? false
    }
    
    var isPicchelin: Bool {
        storeContext.store(for: storeId)?.isPicchelin ?? false
    }
    
    var distance: String {
        if let distance = storeContext.store(for: storeId)?.distance {
            return String(format: "%.1f", distance) + "km"
        }
        return "---"
    }
    
    var closeTime: String {
        storeContext.store(for: storeId)?.close ?? "--:--"
    }
    
    var pickCount: String {
        if let count = storeContext.store(for: storeId)?.pickCount {
            return "\(count)회"
        }
        return "0회"
    }
    
    var totalRating: String {
        if let totalRating = storeContext.store(for: storeId)?.totalRating {
            return "\(totalRating)"
        }
        return "0"
    }
    
    var totalReviewCount: String {
        if let count = storeContext.store(for: storeId)?.totalReviewCount {
            return "\(count)개"
        }
        return "0개"
    }
    
    var storeImageUrls: [String] {
        storeContext.store(for: storeId)?.storeImageUrls ?? []
    }
    
    var hashTags: [String] {
        storeContext.store(for: storeId)?.hashTags ?? []
    }
    
    var totalOrderCount: String {
        if let count = storeContext.store(for: storeId)?.totalOrderCount {
            return "\(count)회"
        }
        return "0회"
    }
}
