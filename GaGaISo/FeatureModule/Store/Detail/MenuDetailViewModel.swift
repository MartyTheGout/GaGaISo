//
//  MenuDetailViewModel.swift
//  GaGaISo
//
//  Created by marty.academy on 5/26/25.
//

import Foundation
import SwiftUI
import Combine

class MenuDetailViewModel: ObservableObject {
    let menu: MenuList
    
    private let imageService: ImageService
    private let orderContext: OrderContext
    
    @Published var menuImage: UIImage?
    @Published var isImageLoading: Bool = false
    @Published var quantity: Int = 1
    
    init(menu: MenuList, imageService: ImageService, orderContext: OrderContext) {
        self.menu = menu
        self.imageService = imageService
        self.orderContext = orderContext
    }
    
    func loadMenuImage() {
        guard !menu.menuImageURL.isEmpty, menuImage == nil, !isImageLoading else { return }
        
        isImageLoading = true
        
        Task {
            let result = await imageService.fetchImageWith(urlString: menu.menuImageURL)
            
            await MainActor.run {
                switch result {
                case .success(let image):
                    self.menuImage = image
                case .failure:
                    break
                }
                self.isImageLoading = false
            }
        }
    }
    
    func increaseQuantity() {
        guard quantity < 99 else { return }
        quantity += 1
    }
    
    func decreaseQuantity() {
        guard quantity > 1 else { return }
        quantity -= 1
    }
    
    func addToOrder() {
        orderContext.addMenuItem(menu: menu, quantity: quantity)
    }
    
    var totalPrice: Int {
        menu.price * quantity
    }
    
    var formattedTotalPrice: String {
        "\(totalPrice)원"
    }
}
