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
    case orderStatus(orderId: String)
    case orderHistory
    case profile
    case notifications

    var targetTab: AppTab {
        switch self {
        case .home, .storeDetail:
            return .home
        case .orderStatus, .orderHistory:
            return .orders
        case .profile:
            return .profile
        case .notifications:
            return .notifications
        }
    }
}
