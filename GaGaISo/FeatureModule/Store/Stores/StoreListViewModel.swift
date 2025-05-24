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
    
    init(locationManager: LocationManager, storeService: StoreService, storeContext: StoreContext) {
        self.locationManager = locationManager
        self.storeService = storeService
        self.storeContext = storeContext
        self.setUpObservers()
    }
    
    func setUpObservers() {
        locationManager.$location
            .compactMap { $0 }
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .removeDuplicates { lhs, rhs in
                lhs.distance(from: rhs) < 15
            }
            .first()
            .receive(on: DispatchQueue.main)
            .flatMap { [weak self] location -> AnyPublisher<[StoreDTO]?, Never> in
                guard let self = self else {
                    return Just(nil).eraseToAnyPublisher()
                }
                
                self.isLoading = true
                self.errorMessage = nil
                
                return Future<[StoreDTO]?, Never> { promise in
                    Task {
                        let result = await self.storeService.getStoresNearBy(
                            category: "",
                            latitude: location.coordinate.latitude,
                            longitude: location.coordinate.longitude,
                            next: "",
                            orderby: .distance
                        )
                        
                        await MainActor.run {
                            switch result {
                            case .success(let stores):
                                promise(.success(stores))
                            case .failure(let error):
                                self.errorMessage = error.localizedDescription
                                promise(.success(nil))
                            }
                        }
                    }
                }
                .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main) 
            .sink { [weak self] stores in
                guard let self = self, let stores = stores else { return }
                
                print("StoreListModel Called")
                dump(stores)
                
                self.storeContext.updateNearbyStores(stores)
                self.storeIds = stores.map { $0.storeID }
                self.isLoading = false
                dump(storeIds)
            }
            .store(in: &cancellables)
    }
}
