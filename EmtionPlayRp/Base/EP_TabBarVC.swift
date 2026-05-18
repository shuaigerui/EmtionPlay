//
//  EP_TabBarVC.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/18.
//

import UIKit

enum TabbarType: CaseIterable {
    case home
    case post
    case chat
    case profile

    var imageName: String {
        switch self {
        case .home:
            return "tab_home"
        case .post:
            return "tab_post"
        case .chat:
            return "tab_chat"
        case .profile:
            return "tab_profile"
        }
    }

    var selImageName: String {
        "\(imageName)_sel"
    }

    var controller: UIViewController {
        switch self {
        case .home:
            return UINavigationController(rootViewController: EP_HomeVC())
        case .post:
            return UINavigationController(rootViewController: EP_PostVC())
        case .chat:
            return UINavigationController(rootViewController: EP_ChatVC())
        case .profile:
            return UINavigationController(rootViewController: EP_ProfileVC())
        }
    }
}

class EP_TabBarVC: UITabBarController {

    private enum Layout {
        static let cornerRadius: CGFloat = 24
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setupTabBarAppearance()
    }

    private func setupViewControllers() {
        viewControllers = TabbarType.allCases.map { type in
            let controller = type.controller
            controller.tabBarItem = makeTabBarItem(for: type)
            return controller
        }
    }

    private func makeTabBarItem(for type: TabbarType) -> UITabBarItem {
        let item = UITabBarItem(
            title: nil,
            image: type.imageName.toImage?.withRenderingMode(.alwaysOriginal),
            selectedImage: type.selImageName.toImage?.withRenderingMode(.alwaysOriginal)
        )
        item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        return item
    }

    private func setupTabBarAppearance() {
        view.backgroundColor = UIColor.color(hexString: "#F8D4E8")

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear
        appearance.backgroundEffect = nil

        let itemAppearance = UITabBarItemAppearance()
        [itemAppearance.normal, itemAppearance.selected, itemAppearance.focused].forEach {
            $0.titleTextAttributes = [.foregroundColor: UIColor.clear]
            $0.iconColor = .clear
        }
        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.isTranslucent = false
        tabBar.tintColor = .clear
        tabBar.unselectedItemTintColor = .clear
        tabBar.layer.cornerRadius = Layout.cornerRadius
        tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tabBar.layer.masksToBounds = true
    }
}
