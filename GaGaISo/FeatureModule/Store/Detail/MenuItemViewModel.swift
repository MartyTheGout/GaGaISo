//
//  MenuViewModel.swift
//  GaGaISo
//
//  Created by marty.academy on 5/25/25.
//

import Foundation
import SwiftUI
import Combine

class MenuItemViewModel: ObservableObject {
    
    let menuId: String
    
    private let imageContext: ImageContext
    private var cancellables = Set<AnyCancellable>()
    
    @Published var menuImage: UIImage?
    @Published var isImageLoading: Bool = false
    @Published var imageLoadError: String?
    
    private let menu: MenuList
    
    init(menu: MenuList, imageContext: ImageContext) {
        self.menuId = menu.menuID
        self.menu = menu
        self.imageContext = imageContext
    }
    
    func loadMenuImage() {
        guard !menu.menuImageURL.isEmpty, menuImage == nil, !isImageLoading else { return }
        
        loadImage(from: menu.menuImageURL)
    }
    
    private func loadImage(from urlString: String) {
        isImageLoading = true
        imageLoadError = nil
        
        Task {
            let result = await imageContext.fetchImageWith(urlString: urlString)
            
            await MainActor.run {
                switch result {
                case .success(let image):
                    self.menuImage = image
                case .failure(let error):
                    self.imageLoadError = error.localizedDescription
                }
                self.isImageLoading = false
            }
        }
    }
}

// MARK: - Computed Properties
extension MenuItemViewModel {
    var name: String {
        menu.name
    }
    
    var description: String {
        menu.description
    }
    
    var price: Int {
        menu.price
    }
    
    var formattedPrice: String {
        "\(menu.price)원"
    }
    
    var isSoldOut: Bool {
        menu.isSoldOut
    }
    
    var tags: [String] {
        menu.tags
    }
    
    var category: String {
        menu.category
    }
    
    var originInformation: String {
        menu.originInformation
    }
    
    var menuImageURL: String {
        menu.menuImageURL
    }
    
    var hasImage: Bool {
        !menu.menuImageURL.isEmpty
    }
}
