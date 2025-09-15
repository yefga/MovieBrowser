//
//  AppDelegate.swift
//  MovieBrowser
//
//  Created by Yefga on 14/09/25.
//

import UIKit
import netfox
import IQKeyboardManagerSwift

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        NFX.sharedInstance().start()
        IQKeyboardManager.shared.isEnabled = true
        return true
    }
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
