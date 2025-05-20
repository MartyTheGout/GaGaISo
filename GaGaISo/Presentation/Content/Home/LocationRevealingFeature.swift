//
//  LocationRevealingFeature.swift
//  GaGaISo
//
//  Created by marty.academy on 5/20/25.
//

import Foundation
import ComposableArchitecture
import CoreLocation

@Reducer
struct LocationRevealingFeature {
    
    @Dependency(\.locationManager) var locationManager
    
    struct State: Equatable {
        var currentLocation: CLLocation?
        var address: String = "주소를 찾는 중..."
        var locationState: LocationState = .idle
        var isLocationPermissionGranted: Bool = false
        
        static func == (lhs: State, rhs: State) -> Bool {
            let locationEqual: Bool
            if let lhsLocation = lhs.currentLocation, let rhsLocation = rhs.currentLocation {
                locationEqual = lhsLocation.coordinate.latitude == rhsLocation.coordinate.latitude &&
                lhsLocation.coordinate.longitude == rhsLocation.coordinate.longitude
            } else {
                locationEqual = lhs.currentLocation == nil && rhs.currentLocation == nil
            }
            
            return locationEqual &&
            lhs.address == rhs.address &&
            lhs.locationState == rhs.locationState &&
            lhs.isLocationPermissionGranted == rhs.isLocationPermissionGranted
        }
    }
    
    enum Action: Equatable {
        case onAppear
        case onDisappear
        case requestLocationPermission
        case startLocationUpdates
        case stopLocationUpdates
        case locationUpdated(CLLocation?, String, LocationState)
        case authorizationStatusChanged(Bool)
        case synchronizeState
        
        static func == (lhs: Action, rhs: Action) -> Bool {
            switch (lhs, rhs) {
            case (.onAppear, .onAppear),
                 (.onDisappear, .onDisappear),
                 (.requestLocationPermission, .requestLocationPermission),
                 (.startLocationUpdates, .startLocationUpdates),
                 (.stopLocationUpdates, .stopLocationUpdates),
                 (.synchronizeState, .synchronizeState):
                return true
                
            case let (.locationUpdated(loc1, addr1, state1), .locationUpdated(loc2, addr2, state2)):
                let locationsEqual: Bool
                
                if let loc1 = loc1, let loc2 = loc2 {
                    locationsEqual = loc1.coordinate.latitude == loc2.coordinate.latitude &&
                    loc1.coordinate.longitude == loc2.coordinate.longitude
                } else {
                    locationsEqual = loc1 == nil && loc2 == nil
                }
                
                return locationsEqual && addr1 == addr2 && state1 == state2
                
            case let (.authorizationStatusChanged(status1), .authorizationStatusChanged(status2)):
                return status1 == status2
                
            default:
                return false
            }
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .merge(
                    .send(.synchronizeState),
                    .run { send in
                        let locationPublisher = NotificationCenter.default.publisher(for: .locationDidUpdate, object: locationManager)
                            .map { _ in
                                (
                                    locationManager.location,
                                    locationManager.koreanAddress,
                                    locationManager.locationState
                                )
                            }
                            .receive(on: DispatchQueue.main)
                        
                        for await (location, address, state) in locationPublisher.values {
                            await send(.locationUpdated(location, address, state))
                        }
                    },
                    .run { send in
                        let authPublisher = NotificationCenter.default.publisher(for: .authorizationStatusChanged, object: locationManager)
                            .compactMap { notification -> Bool? in
                                notification.userInfo?["isGranted"] as? Bool
                            }
                            .receive(on: DispatchQueue.main)
                        
                        for await isGranted in authPublisher.values {
                            await send(.authorizationStatusChanged(isGranted))
                        }
                    },
                    .send(.startLocationUpdates)
                )
                
            case .onDisappear:
                return .send(.stopLocationUpdates)
                
            case .synchronizeState:
                state.currentLocation = locationManager.location
                state.address = locationManager.koreanAddress
                state.locationState = locationManager.locationState
                state.isLocationPermissionGranted = locationManager.isLocationPermissionGranted
                return .none
                
            case .requestLocationPermission:
                locationManager.requestLocationPermission()
                return .none
                
            case .startLocationUpdates:
                locationManager.startUpdatingLocation()
                return .none
                
            case .stopLocationUpdates:
                locationManager.stopUpdatingLocation()
                return .none
                
            case let .locationUpdated(location, address, locationUpdateState):
                state.currentLocation = location
                state.address = address
                state.locationState = locationUpdateState
                return .none
                
            case let .authorizationStatusChanged(isGranted):
                state.isLocationPermissionGranted = isGranted
                
                if isGranted {
                    return .send(.startLocationUpdates)
                }
                return .none
            }
        }
    }
}
