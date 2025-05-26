//
//  AppTab.swift
//  GaGaISo
//
//  Created by marty.academy on 5/26/25.
//

import Foundation

enum AppTab: Int, CaseIterable {
    case home = 0
    case orders = 1
    case notifications = 2
    case profile = 3
    
    var title: String {
        switch self {
        case .home: return "홈"
        case .orders: return "주문"
        case .notifications: return "알림"
        case .profile: return "프로필"
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "house"
        case .orders: return "bag"
        case .notifications: return "bell"
        case .profile: return "person"
        }
    }
}
