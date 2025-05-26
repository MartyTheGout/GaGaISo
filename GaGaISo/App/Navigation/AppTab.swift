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
    case community = 2
    case profile = 3
    
    var title: String {
        switch self {
        case .home: return "홈"
        case .orders: return "주문"
        case .community: return "커뮤니티"
        case .profile: return "프로필"
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .orders: return "list.bullet"
        case .community: return "person.3.fill"
        case .profile: return "person.3.fill"
        }
    }
}
