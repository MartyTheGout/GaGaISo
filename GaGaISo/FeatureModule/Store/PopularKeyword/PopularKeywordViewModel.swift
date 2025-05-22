//
//  PopularSearchViewModel.swift
//  GaGaISo
//
//  Created by marty.academy on 5/22/25.
//

import Foundation

class PopularKeywordViewModel: ObservableObject {
    
    private var storeManager: StoreManager
    
    @Published var searchKeywords: [String] = []
    
    init(storeManager: StoreManager) {
        self.storeManager = storeManager
    }
    
    func loadPopularSearches() async {
        let keywords = await storeManager.getPopularKeyword()
        
        if let keywords {
            await MainActor.run {
                self.searchKeywords = keywords
            }
        }
    }
}
