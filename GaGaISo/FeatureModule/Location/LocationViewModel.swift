//
//  LocationViewModel.swift
//  GaGaISo
//
//  Created by marty.academy on 5/21/25.
//

import Foundation
import Combine
import CoreLocation

class LocationRevealingViewModel: ObservableObject {
    @Published var displayLocation: String = "위치를 가져오는 중..."
    @Published var currentLocation: CLLocation?
    @Published var locationState: LocationState = .idle
    @Published var isLocationPermissionGranted: Bool = false
    
    private let locationManager: LocationManager
    private var cancellables = Set<AnyCancellable>()
    
    init(locationManager: LocationManager) {
        self.locationManager = locationManager
        
        synchronizeState()
        
        setupObservers()
    }
    
    private func setupObservers() {
        locationManager.$location
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                self?.currentLocation = location
            }
            .store(in: &cancellables)
        

        locationManager.$koreanAddress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] address in
                self?.displayLocation = address
            }
            .store(in: &cancellables)
        
        locationManager.$locationState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.locationState = state
            }
            .store(in: &cancellables)
        
        locationManager.$authorizationStatus
            .receive(on: DispatchQueue.main)
            .map { $0 == .authorizedWhenInUse || $0 == .authorizedAlways }
            .sink { [weak self] isGranted in
                self?.isLocationPermissionGranted = isGranted
                
                if isGranted {
                    self?.startLocationUpdates()
                }
            }
            .store(in: &cancellables)
    }
    
    private func synchronizeState() {
        self.currentLocation = locationManager.location
        self.displayLocation = locationManager.koreanAddress
        self.locationState = locationManager.locationState
        self.isLocationPermissionGranted = locationManager.isLocationPermissionGranted
    }
    
    // MARK: - Public Methods
    func requestLocationPermission() {
        locationManager.requestLocationPermission()
    }
    
    func startLocationUpdates() {
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }
}
