//
//  OrderCardViewModel.swift
//  GaGaISo
//
//  Created by marty.academy on 6/9/25.
//

import Foundation
import UIKit
import Combine

class OrderCardViewModel: ObservableObject {
    let order: OrderDetailDTO
    
    private let imageContext: ImageContext
    private var cancellables = Set<AnyCancellable>()
    
    @Published var storeImage: UIImage?
    @Published var isStoreImageLoading: Bool = false
    @Published var menuImages: [String: UIImage] = [:] // menuImageURL을 키로 사용
    @Published var loadingMenuImages: Set<String> = []
    
    init(order: OrderDetailDTO, imageContext: ImageContext) {
        self.order = order
        self.imageContext = imageContext
    }
    
    // MARK: - Store Image Loading
    func loadStoreImage() {
        guard let storeImageURL = order.store.storeImageUrls.first,
              !storeImageURL.isEmpty,
              storeImage == nil,
              !isStoreImageLoading else { return }
        
        isStoreImageLoading = true
        
        Task {
            let result = await imageContext.fetchImageWith(urlString: storeImageURL)
            
            await MainActor.run {
                switch result {
                case .success(let image):
                    self.storeImage = image
                case .failure:
                    break
                }
                self.isStoreImageLoading = false
            }
        }
    }
    
    // MARK: - Menu Images Loading
    func loadMenuImage(for menuImageURL: String) {
        guard !menuImageURL.isEmpty,
              menuImages[menuImageURL] == nil,
              !loadingMenuImages.contains(menuImageURL) else { return }
        
        loadingMenuImages.insert(menuImageURL)
        
        Task {
            let result = await imageContext.fetchImageWith(urlString: menuImageURL)
            
            await MainActor.run {
                switch result {
                case .success(let image):
                    self.menuImages[menuImageURL] = image
                case .failure:
                    break
                }
                self.loadingMenuImages.remove(menuImageURL)
            }
        }
    }
    
    func getMenuImage(for menuImageURL: String) -> UIImage? {
        return menuImages[menuImageURL]
    }
    
    func isLoadingMenuImage(for menuImageURL: String) -> Bool {
        return loadingMenuImages.contains(menuImageURL)
    }
    
    // MARK: - Helper Methods
    var orderStatusDisplayName: String {
        switch order.currentOrderStatus {
        case "PENDING_APPROVAL": return "승인대기"
        case "APPROVED": return "주문승인"
        case "IN_PROGRESS": return "조리중"
        case "READY_FOR_PICKUP": return "픽업대기"
        case "PICKED_UP": return "픽업완료"
        default: return order.currentOrderStatus
        }
    }
    
    func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else { return dateString }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "M월 d일 HH:mm"
        return displayFormatter.string(from: date)
    }
    
    var totalMenuCount: Int {
        order.orderMenuList.reduce(0) { $0 + $1.quantity }
    }
}
