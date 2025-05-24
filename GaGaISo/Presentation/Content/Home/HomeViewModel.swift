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
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentTab = 0
    
    init(locationManager: LocationManager, networkHandler: StrategicNetworkHandler) {
        self.locationManager = locationManager
        self.networkHandler = networkHandler
    }
}
