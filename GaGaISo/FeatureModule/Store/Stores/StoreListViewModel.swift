//
//  StoreListViewModel.swift
//  GaGaISo
//
//  Created by marty.academy on 5/21/25.
//

import Foundation
import Combine

class StoreListViewModel: ObservableObject {
    private let locationManager: LocationManager
    private let storeService: StoreService
    private let storeContext: StoreContext
    private var cancellables = Set<AnyCancellable>()
    
    @Published var storeIds: [String] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var currentTab = 0 {
        didSet {
            if currentTab != oldValue {
                loadStoresForCurrentTab()
            }
        }
    }
    
    init(locationManager: LocationManager, storeService: StoreService, storeContext: StoreContext) {
        self.locationManager = locationManager
        self.storeService = storeService
        self.storeContext = storeContext
        self.setUpObservers()
        
        storeContext.$nearbyStoresLastUpdated
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    func setUpObservers() {
        locationManager.$location
            .compactMap { $0 }
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .removeDuplicates { lhs, rhs in
                lhs.distance(from: rhs) < 15
            }
            .sink { [weak self] location in
                self?.loadStoresForCurrentTab()
            }
            .store(in: &cancellables)
    }
    
    private func loadStoresForCurrentTab() {
        switch currentTab {
        case 0:
            loadNearbyPicchelinStores()
        case 1:
            loadLikedStores()
        default:
            break
        }
    }
    
    private func loadNearbyPicchelinStores() {
        guard let location = locationManager.location else {
            errorMessage = "위치 정보를 가져올 수 없습니다."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            let result = await storeService.getStoresNearBy(
                category: "",
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                next: "",
                orderby: .distance
            )
            
            await MainActor.run {
                switch result {
                case .success(let stores):
                    let picchelinStores = stores.filter { $0.isPicchelin }
                    self.storeContext.updateNearbyStores(picchelinStores)
                    self.storeIds = picchelinStores.map { $0.storeID }
                    
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    print("Error loading nearby stores: \(error)")
                }
                self.isLoading = false
            }
        }
    }
    
    private func loadLikedStores() {
        isLoading = true
        errorMessage = nil
        
        Task {
            let result = await storeService.getLikedStores(category: "", next: "")
            
            await MainActor.run {
                switch result {
                case .success(let stores):
                    self.storeContext.updateNearbyStores(stores)
                    self.storeIds = stores.map { $0.storeID }
                    
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    print("Error loading liked stores: \(error)")
                }
                self.isLoading = false
            }
        }
    }
}
