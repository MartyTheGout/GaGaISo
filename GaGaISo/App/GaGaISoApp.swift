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


@main
struct GaGaISoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        @Dependency(\.authStore) var authStore
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
        }
    }
}
