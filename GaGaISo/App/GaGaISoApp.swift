//
//  GaGaISoApp.swift
//  GaGaISo
//
//  Created by marty.academy on 5/13/25.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth
import ComposableArchitecture
import Toasts

@main
struct GaGaISoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    //testMode
    var forceLoginProcess = false
    
    init() {
        @Dependency(\.authStore) var authStore
        
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
            AppEntryView(
                store: Store(initialState: AppFeature.State()) {
                    AppFeature()
                }
            )
            .onOpenURL(perform: { url in
                if AuthApi.isKakaoTalkLoginUrl(url) {
                    _ = AuthController.handleOpenUrl(url: url)
                }
            })
            .installToast(position: .bottom)
        }
    }
}
