//
//  LocationManager.swift
//  GaGaISo
//
//  Created by marty.academy on 5/20/25.
//

import Foundation
import Combine
import CoreLocation

enum LocationState: Equatable {
    case idle
    case loading
    case success
    case error(Error)
    
    static func == (lhs: LocationState, rhs: LocationState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading), (.success, .success):
            return true
        case let (.error(error1), .error(error2)):
            return error1.localizedDescription == error2.localizedDescription
        default:
            return false
        }
    }
}

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    private var locationManager = CLLocationManager()
    
    @Published var location: CLLocation?
    
    var latitude: Double {
        location?.coordinate.latitude ?? 0.0
    }
    
    var longitude: Double {
        location?.coordinate.longitude ?? 0.0
    }
    
    @Published var koreanAddress: String = "주소를 찾는 중..."
    @Published var locationState: LocationState = .idle
    @Published var authorizationStatus: CLAuthorizationStatus
    
    var isLocationPermissionGranted: Bool {
        authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }
    
    override init() {
        let manager = CLLocationManager()
        self.authorizationStatus = manager.authorizationStatus
        
        super.init()
        setupLocationManager()
    }
    
    func startUpdatingLocation() {
        if isLocationPermissionGranted {
            locationState = .loading
            locationManager.startUpdatingLocation()
        } else {
            requestLocationPermission()
        }
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func requestLocationPermission() {
        if isLocationPermissionGranted {
            startUpdatingLocation()
            return
        }
        
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        
        if isLocationPermissionGranted {
            startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    private func getKoreanAddress(from location: CLLocation) {
        locationState = .loading
        let geocoder = CLGeocoder()
        
        let locale = Locale(identifier: "ko_KR")
        
        geocoder.reverseGeocodeLocation(location, preferredLocale: locale) { [weak self] placemarks, error in
            guard let self = self else { return }
            
            if let error = error {
                self.locationState = .error(error)
                self.koreanAddress = "주소를 찾을 수 없습니다."
                return
            }
            
            guard let placemark = placemarks?.first else {
                self.koreanAddress = "주소를 찾을 수 없습니다."
                return
            }
            
            let components = [
                placemark.administrativeArea,
                placemark.subLocality,
                placemark.thoroughfare,
                placemark.subThoroughfare,
                placemark.name
            ]
            
            let address = components.compactMap { $0 }.joined(separator: " ")
            
            if !address.isEmpty {
                self.koreanAddress = address
                self.locationState = .success
            } else {
                self.koreanAddress = "상세 주소를 찾을 수 없습니다."
                self.locationState = .error(NSError(domain: "LocationManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "주소 정보 없음"]))
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        getKoreanAddress(from: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationState = .error(error)
        koreanAddress = "위치를 가져오는 데 실패했습니다."
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        handleAuthorizationChange(manager.authorizationStatus)
    }
    
    private func handleAuthorizationChange(_ status: CLAuthorizationStatus) {
        authorizationStatus = status
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdatingLocation()
        case .denied, .restricted:
            locationState = .error(NSError(domain: "LocationManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "위치 권한이 없습니다."]))
            koreanAddress = "위치 권한이 없습니다."
        case .notDetermined:
            locationState = .idle
        @unknown default:
            break
        }
    }
}

