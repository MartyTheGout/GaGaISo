//
//  AppNavigationManager.swift
//  GaGaISo
//
//  Created by marty.academy on 5/26/25.
//
import SwiftUI
import Combine
import iamport_ios

class AppNavigationManager: ObservableObject {
    static let shared = AppNavigationManager()
    
    @Published var selectedTab: AppTab = .home
    @Published var pendingDestination: AppDestination?
    
    @Published var homeNavigationPath = NavigationPath()
    @Published var ordersNavigationPath = NavigationPath()
    @Published var communityNavigationPath = NavigationPath()
    @Published var profileNavigationPath = NavigationPath()
    
    var pendingDeepLink: URL?
    
    private init() {}
    
    //MARK: - 로그인 완료 후 pending deep link 처리
    func processPendingDeepLink() {
        if let pendingURL = pendingDeepLink {
            handleDeepLink(url: pendingURL)
            pendingDeepLink = nil
        }
    }
    
    // MARK: - Navigation
    func navigate(to destination: AppDestination) {
        print("🧭 Navigating to: \(destination)")
        
        if selectedTab != destination.targetTab {
            selectedTab = destination.targetTab
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.performInternalNavigation(to: destination)
            }
        } else {
            self.performInternalNavigation(to: destination)
        }
    }
    
    func popBack() {
        switch selectedTab {
        case .home:
            if !homeNavigationPath.isEmpty {
                homeNavigationPath.removeLast()
            }
        case .orders:
            if !ordersNavigationPath.isEmpty {
                ordersNavigationPath.removeLast()
            }
        case .community:
            if !communityNavigationPath.isEmpty {
                communityNavigationPath.removeLast()
            }
        case .profile:
            if !profileNavigationPath.isEmpty {
                profileNavigationPath.removeLast()
            }
        }
    }
    
    private func performInternalNavigation(to destination: AppDestination) {
        switch destination {
        case .home:
            break
            
        case .storeDetail:
            homeNavigationPath.append(destination)
            
        case .memuDetail:
            homeNavigationPath.append(destination)
            
        case .orderStatus:
            ordersNavigationPath.append(destination)
            
        case .profile:
            break
            
        case .notifications:
            break
            
        }
    }
    
    // MARK: - Path Clearance
    private func clearAllPaths() {
        homeNavigationPath = NavigationPath()
        ordersNavigationPath = NavigationPath()
        communityNavigationPath = NavigationPath()
        profileNavigationPath = NavigationPath()
    }
    
    private func clearHomePath() {
        homeNavigationPath = NavigationPath()
    }
    
    private func clearOrdersPath() {
        ordersNavigationPath = NavigationPath()
    }
    
    // MARK: - 주문 완료 후 네비게이션
    func handleOrderCompletion() {
        DispatchQueue.main.async { [weak self] in
            self?.selectedTab = .orders
        }
    }
    
    // MARK: - Push Notification Handling
    func handlePushNotification(userInfo: [AnyHashable: Any]) {
        // Push notification의 payload를 파싱하여 적절한 destination으로 이동
        
        if let type = userInfo["type"] as? String {
            switch type {
            case "order_status":
                if let orderId = userInfo["order_id"] as? String {
                    navigate(to: .orderStatus)
                }
            case "store_promotion":
                if let storeId = userInfo["store_id"] as? String {
                    navigate(to: .storeDetail(storeId: storeId))
                }
            default:
                navigate(to: .notifications)
            }
        }
    }
    
    // MARK: - Deep Link Handling
    func handleDeepLink(url: URL) {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        guard let host = components?.host else { return }
        
        // For PG Payment Link
        if url.scheme == "gagaiso" {
            Iamport.shared.receivedURL(url)
            return
        }
        
        // For Serverside push
        switch host {
        case "store":
            if let storeId = components?.queryItems?.first(where: { $0.name == "id" })?.value {
                navigate(to: .storeDetail(storeId: storeId))
            }
        case "order":
            navigate(to: .orderStatus)
            
        default:
            navigate(to: .home)
        }
    }
}
