//
//  HomeFeature.swift
//  GaGaISo
//
//  Created by marty.academy on 5/19/25.
//

// HomeViewModel.swift
import Foundation
import Combine

class HomeViewModel: ObservableObject {
    private let networkHandler: StrategicNetworkHandler
    private let locationManager: LocationManager
    private var cancellables = Set<AnyCancellable>()
    
    @Published var stores: NearbyStoresDTO?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentTab = 0
    
    init(locationManager: LocationManager, networkHandler: StrategicNetworkHandler) {
        self.locationManager = locationManager
        self.networkHandler = networkHandler
        
        setUpObservers()
    }
    
    func setUpObservers() {
        locationManager.$location
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .removeDuplicates { lhs, rhs in
                lhs.distance(from: rhs) < 15
            }
            .flatMap { [weak self] location -> AnyPublisher<NearbyStoresDTO?, Never> in
                guard let self = self else {
                    return Just(nil).eraseToAnyPublisher()
                }
                
                self.isLoading = true
                self.errorMessage = nil
                
                return Future<NearbyStoresDTO?, Never> { promise in
                    Task {
                        let result = await self.networkHandler.request(
                            StoreRouter.v1LocationBasedStore(
                                category: "",
                                longitude: location.coordinate.longitude,
                                latitude: location.coordinate.latitude,
                                next: "",
                                limit: 5,
                                orderBy: .distance
                            ),
                            type: NearbyStoresDTO.self
                        )
                        
                        await MainActor.run {
                            switch result {
                            case .success(let stores):
                                promise(.success(stores))
                            case .failure(let error):
                                self.errorMessage = error.localizedDescription
                                promise(.success(nil))
                            }
                            self.isLoading = false
                        }
                    }
                }
                .eraseToAnyPublisher()
            }
            .assign(to: \.stores, on: self)
            .store(in: &cancellables)
    }
    
    func onAppear() async {
        if locationManager.isLocationPermissionGranted {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestLocationPermission()
        }
    }
    
    func onDisappear() {
        locationManager.stopUpdatingLocation()
    }
    
    func refreshStores() {
        if let location = locationManager.location {
            Task {
                isLoading = true
                errorMessage = nil
                
                let result = await networkHandler.request(
                    StoreRouter.v1LocationBasedStore(
                        category: "",
                        longitude: location.coordinate.longitude,
                        latitude: location.coordinate.latitude,
                        next: "",
                        limit: 5,
                        orderBy: .distance
                    ),
                    type: NearbyStoresDTO.self
                )
                
                switch result {
                case .success(let stores):
                    self.stores = stores
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
                
                isLoading = false
            }
        }
    }
}
