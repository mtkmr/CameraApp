//
//  AppDelegate.swift
//  CameraApp
//
//  Created by Masato Takamura on 2021/10/01.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        let vc = BaseViewController()
        window.rootViewController = vc
        window.makeKeyAndVisible()
        self.window = window
        return true
    }


}

