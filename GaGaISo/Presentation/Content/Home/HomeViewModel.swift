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
    private let locationManager: LocationManager
    private var cancellables = Set<AnyCancellable>()
    
    init(locationManager: LocationManager) {
        self.locationManager = locationManager
        
    }

    func onAppear() {
        
    }
    
    func onDisappear() {
    
    }
}
