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
    
    init() {
        if UserDefaults.standard.string(forKey: "deviceToken") == nil {
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
                    .onOpenURL(perform: { url in
                        if (AuthApi.isKakaoTalkLoginUrl(url)) {
                            AuthController.handleOpenUrl(url: url)
                        }
                    })
            }
        }
    }
}
