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

extension EnvironmentValues {
    var diContainer: DIContainer {
        get { self[DIContainerKey.self] }
        set { self[DIContainerKey.self] = newValue }
    }
}
