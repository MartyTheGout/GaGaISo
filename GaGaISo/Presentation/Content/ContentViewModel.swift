//
//  ContentViewModel.swift
//  GaGaISo
//
//  Created by marty.academy on 5/21/25.
//

import Foundation

enum Tab {
    case home
    case orders
    case favorites
    case profile
}

class ContentViewModel: ObservableObject {
    @Published var selectedTab: Tab = .home
}
