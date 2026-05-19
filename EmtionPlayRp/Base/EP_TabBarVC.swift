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
        static let tabBarContentHeight: CGFloat = 49
        static let topCornerRadius: CGFloat = 24
    }

    init() {
        super.init(nibName: nil, bundle: nil)
        setValue(EP_TabBar(), forKey: "tabBar")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setupTabBarAppearance()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutTabBarToBottom()
    }

    private func setupViewControllers() {
        viewControllers = TabbarType.allCases.map { type in
            let controller = type.controller
            controller.tabBarItem = makeTabBarItem(for: type)
            return controller
        }
    }

    private func makeTabBarItem(for type: TabbarType) -> UITabBarItem {
        UITabBarItem(
            title: nil,
            image: type.imageName.toImage?.withRenderingMode(.alwaysOriginal),
            selectedImage: type.selImageName.toImage?.withRenderingMode(.alwaysOriginal)
        )
    }

    private func setupTabBarAppearance() {
        view.backgroundColor = UIColor.color(hexString: "#F8D4E8")

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()
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
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
        tabBar.isTranslucent = false
        tabBar.tintColor = .clear
        tabBar.unselectedItemTintColor = .clear
        tabBar.shadowImage = UIImage()
        tabBar.backgroundImage = UIImage()
        tabBar.backgroundColor = .white
        tabBar.barTintColor = .white
    }

    private func layoutTabBarToBottom() {
        let safeBottom = view.safeAreaInsets.bottom
        let tabBarHeight = Layout.tabBarContentHeight + safeBottom

        var frame = tabBar.frame
        frame.size.width = view.bounds.width
        frame.size.height = tabBarHeight
        frame.origin.x = 0
        frame.origin.y = view.bounds.height - tabBarHeight
        tabBar.frame = frame

        tabBar.layer.cornerRadius = Layout.topCornerRadius
        tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tabBar.layer.masksToBounds = true
    }
}
