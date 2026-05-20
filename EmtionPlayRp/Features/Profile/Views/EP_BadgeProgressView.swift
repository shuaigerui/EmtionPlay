//
//  EP_BadgeProgressView.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/20.
//

import UIKit

final class EP_BadgeProgressView: UIView {

    var progress: CGFloat = 0 {
        didSet { setNeedsLayout() }
    }

    private let trackView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 6
        view.clipsToBounds = true
        return view
    }()

    private let fillView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.cornerRadius = 6
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(trackView)
        addSubview(fillView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        trackView.frame = bounds
        let fillWidth = bounds.width * min(max(progress, 0), 1)
        fillView.frame = CGRect(x: 0, y: 0, width: fillWidth, height: bounds.height)
    }
}
