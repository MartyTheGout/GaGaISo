//
//  NotificationManager.swift
//  LoginFeatureExperiment
//
//  Created by marty.academy on 5/11/25.
//

import UIKit
import UserNotifications

final class NotificationManager {
    init() {
        print("NotificationManager init")
        requestAuthorizationAndRegister()
    }

    deinit {
        print("NotificationManager deinit")
    }

    private func requestAuthorizationAndRegister() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("Push Permission not allowed")
            }
        }
    }
}
