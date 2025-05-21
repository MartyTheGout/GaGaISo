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
    @Published var currentLocation: CLLocation?
    @Published var address: String = "주소를 찾는 중..."
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
            .sink { [weak self] location in
                self?.currentLocation = location
            }
            .store(in: &cancellables)
        

        locationManager.$koreanAddress
            .sink { [weak self] address in
                self?.address = address
            }
            .store(in: &cancellables)
        
        locationManager.$locationState
            .sink { [weak self] state in
                self?.locationState = state
            }
            .store(in: &cancellables)
        
        locationManager.$authorizationStatus
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
        self.address = locationManager.koreanAddress
        self.locationState = locationManager.locationState
        self.isLocationPermissionGranted = locationManager.isLocationPermissionGranted
    }
    
    // MARK: - Public Methods
    
    func onAppear() {
        startLocationUpdates()
    }
    
    func onDisappear() {
        stopLocationUpdates()
    }
    
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
