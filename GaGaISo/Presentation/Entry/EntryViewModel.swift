//
//  EntryFeature.swift
//  GaGaISo
//
//  Created by marty.academy on 5/17/25.
//

import Foundation
import Combine

class AppEntryViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    private var authManager: AuthManagerProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(authManager: AuthManagerProtocol) {
        self.authManager = authManager
        
        if let authManager = authManager as? AuthenticationManager {
            authManager.$isLoggedIn
                .assign(to: &$isLoggedIn)
        }
        
        Task {
            await authManager.bootstrap()
        }
    }
}
