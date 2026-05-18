//
//  AppDelegate.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/18.
//

import UIKit
import IQKeyboardManager
import Toast_Swift
@_exported import SnapKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        
        ToastManager.shared.position = .center
        
        initializeWindow()
        
        return true
    }


    private func initializeWindow() {

        window = UIWindow(frame: UIScreen.main.bounds)
        
//        let launchVC = VE_LaunchVC()
//        launchVC.completion = {
//            if VE_CurrentUser.isLoggedIn {
//                self.window?.rootViewController = VE_TabBarVC()
//            } else {
//                self.window?.rootViewController = UINavigationController(rootViewController: VE_LoginVC())
//            }
//            self.window?.makeKeyAndVisible()
//        }
//        self.window?.rootViewController = launchVC
        self.window?.rootViewController = UINavigationController(rootViewController: EP_WelcomeVC())
        self.window?.makeKeyAndVisible()
    }
}

