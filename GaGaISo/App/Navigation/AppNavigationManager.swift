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
    @Published var notificationsNavigationPath = NavigationPath()
    @Published var profileNavigationPath = NavigationPath()
    
    private init() {}
    
    // MARK: - 전역 네비게이션 메서드
    func navigate(to destination: AppDestination) {
        print("🧭 Navigating to: \(destination)")
        
        selectedTab = destination.targetTab
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.performInternalNavigation(to: destination)
        }
    }
    
    private func performInternalNavigation(to destination: AppDestination) {
        switch destination {
        case .home:
            clearAllPaths()
            
        case .storeDetail(let storeId):
            clearHomePath()
            homeNavigationPath.append(destination)
            
        case .orderStatus(let orderId):
            clearOrdersPath()
            ordersNavigationPath.append(destination)
            
        case .orderHistory:
            clearOrdersPath()
            ordersNavigationPath.append(destination)
            
        case .profile:
            clearAllPaths()
            
        case .notifications:
            clearAllPaths()
        }
    }
    
    // MARK: - 패스 클리어 메서드들
    private func clearAllPaths() {
        homeNavigationPath = NavigationPath()
        ordersNavigationPath = NavigationPath()
        notificationsNavigationPath = NavigationPath()
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
        case "orders":
            navigate(to: .orderHistory)
        default:
            navigate(to: .home)
        }
    }
}

// MARK: - 메인 앱 뷰
struct MainAppView: View {
    @StateObject private var navigationManager = AppNavigationManager.shared
    @Environment(\.diContainer) private var diContainer
    
    var body: some View {
        TabView(selection: $navigationManager.selectedTab) {
            // 홈 탭
            NavigationStack(path: $navigationManager.homeNavigationPath) {
                HomeView(viewModel: diContainer.getHomeViewModel())
                    .navigationDestination(for: AppDestination.self) { destination in
                        destinationView(for: destination)
                    }
            }
            .tabItem {
                Image(systemName: AppTab.home.icon)
                Text(AppTab.home.title)
            }
            .tag(AppTab.home)
            
            // 주문 탭
            NavigationStack(path: $navigationManager.ordersNavigationPath) {
                OrdersView()
                    .navigationDestination(for: AppDestination.self) { destination in
                        destinationView(for: destination)
                    }
            }
            .tabItem {
                Image(systemName: AppTab.orders.icon)
                Text(AppTab.orders.title)
            }
            .tag(AppTab.orders)
            
            // 알림 탭
            NavigationStack(path: $navigationManager.notificationsNavigationPath) {
                NotificationsView()
            }
            .tabItem {
                Image(systemName: AppTab.notifications.icon)
                Text(AppTab.notifications.title)
            }
            .tag(AppTab.notifications)
            
            // 프로필 탭
            NavigationStack(path: $navigationManager.profileNavigationPath) {
                ProfileView()
            }
            .tabItem {
                Image(systemName: AppTab.profile.icon)
                Text(AppTab.profile.title)
            }
            .tag(AppTab.profile)
        }
    }
    
    @ViewBuilder
    private func destinationView(for destination: AppDestination) -> some View {
        switch destination {
        case .storeDetail(let storeId):
            StoreDetailView(
                viewModel: diContainer.getStoreDetailViewModel(storeId: storeId)
            )
        case .orderStatus(let orderId):
            OrderStatusView(orderId: orderId)
        case .orderHistory:
            OrderHistoryView()
        default:
            EmptyView()
        }
    }
}

// MARK: - 임시 뷰들
//struct OrdersView: View {
//    var body: some View {
//        VStack {
//            Text("주문 목록")
//                .font(.largeTitle)
//            
//            Button("테스트: 주문 상태로 이동") {
//                AppNavigationManager.shared.navigate(to: .orderStatus(orderId: "test123"))
//            }
//            .padding()
//            .background(Color.blue)
//            .foregroundColor(.white)
//            .cornerRadius(8)
//        }
//        .navigationTitle("주문")
//    }
//}

struct OrderStatusView: View {
    let orderId: String
    
    var body: some View {
        VStack {
            Text("주문 상태")
                .font(.largeTitle)
            
            Text("주문 ID: \(orderId)")
                .font(.title2)
                .padding()
        }
        .navigationTitle("주문 상태")
    }
}

struct OrderHistoryView: View {
    var body: some View {
        VStack {
            Text("주문 내역")
                .font(.largeTitle)
        }
        .navigationTitle("주문 내역")
    }
}

struct NotificationsView: View {
    var body: some View {
        VStack {
            Text("알림")
                .font(.largeTitle)
            
            Button("테스트: 가게 상세로 이동") {
                AppNavigationManager.shared.navigate(to: .storeDetail(storeId: "store_001"))
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .navigationTitle("알림")
    }
}
