//
//  AppDelegate.swift
//  LoginFeatureExperiment
//
//  Created by marty.academy on 5/11/25.
//

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02x", $0) }.joined()
        print("Successfully Device Token Register: \(token)")
        UserDefaults.standard.set(token, forKey: "deviceToken")
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to Register Device Token: \(error.localizedDescription)")
    }
}
