//
//  Environment.swift
//  GaGaISo
//
//  Created by marty.academy on 5/21/25.
//

import SwiftUI

struct DIContainerKey: EnvironmentKey {
    static let defaultValue = DIContainer()
}

struct NavigationManagerKey: EnvironmentKey {
    static let defaultValue = AppNavigationManager()
}

extension EnvironmentValues {
    var diContainer: DIContainer {
        get { self[DIContainerKey.self] }
        set { self[DIContainerKey.self] = newValue }
    }
    
    var navigationManager: AppNavigationManager {
        get { self[NavigationManagerKey.self] }
        set { self[NavigationManagerKey.self] = newValue }
    }
}
