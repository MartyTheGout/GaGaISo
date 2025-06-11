//
//  AppDestination.swift
//  GaGaISo
//
//  Created by marty.academy on 5/26/25.
//

import Foundation

enum AppDestination: Hashable {
    case home
    case storeDetail(storeId: String)
    case orderStatus
    case memuDetail(menu: MenuList)
    case profile
    case notifications

    var targetTab: AppTab {
        switch self {
        case .home, .storeDetail, .memuDetail:
            return .home
        case .orderStatus:
            return .orders
        case .profile:
            return .profile
        case .notifications:
            return .community
        }
    }
}
