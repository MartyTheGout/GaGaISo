//
//  GaGaISoApp.swift
//  GaGaISo
//
//  Created by marty.academy on 5/13/25.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth

@main
struct GaGaISoApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    let diContainer = DIContainer()
    
    init() {
        let authStore = diContainer.authStore
        appDelegate.authStore = authStore
        
        if authStore.deviceToken == nil {
            let _ = NotificationManager()
        } else {
            print("Device Token already exists: App start without device token registration")
        }
        
        let kakaoNativeAppKey = APIKey.KAKAO_NATIVE_APP_KEY
        KakaoSDK.initSDK(appKey: kakaoNativeAppKey)
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                LoginView()
                    .environment(\.diContainer, diContainer)
                    .onOpenURL(perform: { url in
                        if (AuthApi.isKakaoTalkLoginUrl(url)) {
                            _ = AuthController.handleOpenUrl(url: url)
                        }
                    })
            }
        }
    }
}
