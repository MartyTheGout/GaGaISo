//
//  AuthStoreKey.swift
//  GaGaISo
//
//  Created by marty.academy on 5/13/25.
//

import SwiftUI

struct DIContainerKey: EnvironmentKey {
    static let defaultValue: DIContainer = DIContainer()
}

extension EnvironmentValues {
    var diContainer: DIContainer {
        get { self[DIContainerKey.self] }
        set { self[DIContainerKey.self] = newValue }
    }
}
