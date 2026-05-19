//
//  EP_TabBar.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/19.
//

import UIKit

final class EP_TabBar: UITabBar {

    private enum Layout {
        static let contentHeight: CGFloat = 49
        static let topCornerRadius: CGFloat = 24
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var fitted = super.sizeThatFits(size)
        fitted.height = Layout.contentHeight + safeAreaInsets.bottom
        return fitted
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = Layout.topCornerRadius
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.masksToBounds = true

        let bottomInset = safeAreaInsets.bottom
        guard bottomInset > 0 else { return }

        let iconAreaTop = bounds.height - bottomInset - Layout.contentHeight
        for subview in subviews {
            guard NSStringFromClass(type(of: subview)).contains("UITabBarButton") else { continue }
            var frame = subview.frame
            frame.origin.y = iconAreaTop + (Layout.contentHeight - frame.height) / 2
            subview.frame = frame
        }
    }
}
