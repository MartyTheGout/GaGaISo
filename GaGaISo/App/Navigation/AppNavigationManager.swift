//
//  AppNavigationManager.swift
//  GaGaISo
//
//  Created by marty.academy on 5/26/25.
//
import SwiftUI
import Combine

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
    
    // MARK: - 전역 네비게이션 메서드
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
    
    private func performInternalNavigation(to destination: AppDestination) {
        switch destination {
        case .home:
            clearAllPaths()
            
        case .storeDetail:
            homeNavigationPath.append(destination)
            
        case .orderStatus:
            clearOrdersPath()
            ordersNavigationPath.append(destination)
            
        case .profile:
            clearAllPaths()
            
        case .notifications:
            clearAllPaths()
            
        case .memuDetail:
            homeNavigationPath.append(destination)
        }
    }
    
    // MARK: - 패스 클리어 메서드들
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
    func handleOrderCompletion(orderId: String) {
        navigate(to: .orderStatus(orderId: orderId))
    }
    
    // MARK: - Push Notification 처리
    func handlePushNotification(userInfo: [AnyHashable: Any]) {
        // Push notification의 payload를 파싱하여 적절한 destination으로 이동
        
        if let type = userInfo["type"] as? String {
            switch type {
            case "order_status":
                if let orderId = userInfo["order_id"] as? String {
                    navigate(to: .orderStatus(orderId: orderId))
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
    
    // MARK: - Deep Link 처리
    func handleDeepLink(url: URL) {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        guard let host = components?.host else { return }
        
        switch host {
        case "store":
            if let storeId = components?.queryItems?.first(where: { $0.name == "id" })?.value {
                navigate(to: .storeDetail(storeId: storeId))
            }
        case "order":
            if let orderId = components?.queryItems?.first(where: { $0.name == "id" })?.value {
                navigate(to: .orderStatus(orderId: orderId))
            }
        default:
            navigate(to: .home)
        }
    }
}
