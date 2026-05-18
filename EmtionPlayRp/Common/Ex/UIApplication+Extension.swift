//
//  UIApplication+Extension.swift
//  SecurePixRp
//
//  Created by  mac on 2026/2/27.
//

import UIKit

extension UIApplication {
    
    class var window: UIWindow? {
        get{
            if let appDelegate = UIApplication.shared.delegate,
               let lendo_window = appDelegate.window {
                return lendo_window
            }
            return UIApplication.shared.keyWindow
        }
    }
    
    /// 获取当前keyWindow（兼容iOS 13+）
    var keyWindowCompat: UIWindow? {
        if #available(iOS 13.0, *) {
            return connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
        } else {
            return keyWindow
        }
    }
    
    // 当前控制器
    class func topController(controller: UIViewController? = window?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topController(controller: presented)
        }
        return controller
    }
}
