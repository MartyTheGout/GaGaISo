//
//  GaGaISoApp.swift
//  GaGaISo
//
//  Created by marty.academy on 5/13/25.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth
import Toasts

@main
struct GaGaISoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let diContainer = DIContainer()
    
    private let navigationManager = AppNavigationManager.shared
    
    //testMode
    var forceLoginProcess = false
    
    init() {
        let authStore = diContainer.authStore
        appDelegate.authStore = authStore
        
        if authStore.deviceToken == nil {
            let _ = NotificationManager()
        } else {
            print("Device Token already exists: App start without device token registration")
        }
        
        if forceLoginProcess {
            authStore.accessToken = nil
            authStore.refreshToken = nil
        }
        
        let kakaoNativeAppKey = APIKey.KAKAO_NATIVE_APP_KEY
        KakaoSDK.initSDK(appKey: kakaoNativeAppKey)
    }
    
    var body: some Scene {
        WindowGroup {
            AppEntryView(viewModel: diContainer.getEntryViewModel())
                .environment(\.diContainer, diContainer)
                .onOpenURL(perform: { url in
                    if AuthApi.isKakaoTalkLoginUrl(url) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }else {
                        handleDeepLink(url: url)
                    }
                })
                .installToast(position: .bottom)
        }
    }
    
    private func handleDeepLink(url: URL) {
        if diContainer.authManager.isLoggedIn {
            navigationManager.handleDeepLink(url: url)
        } else {
            navigationManager.pendingDeepLink = url
        }
    }
}
