//
//  PopularSearchViewModel.swift
//  GaGaISo
//
//  Created by marty.academy on 5/22/25.
//

import Foundation

class PopularKeywordViewModel: ObservableObject {
    
    private var storeService: StoreService
    
    @Published var searchKeywords: [String] = []
    
    init(storeService: StoreService) {
        self.storeService = storeService
    }
    
    func loadPopularSearches() async {
        let keywords = await storeService.getPopularKeyword()
        
        await MainActor.run {
            switch keywords {
            case .success(let keywords):
                self.searchKeywords = keywords
            case .failure:
                //TODO: error.localizedDescription => Notification / Combine 으로 상위 뷰와 엮어버리면 되지 않을까?
                self.searchKeywords = ["-"] //TODO:  .failure 인 경우에 errorMessage 를 하나의 ViewModel에서 업데이트 해주어야한다.
            }
        }
    }
}
