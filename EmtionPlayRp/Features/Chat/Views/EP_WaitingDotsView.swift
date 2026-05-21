//
//  EP_WaitingDotsView.swift
//  EmtionPlayRp
//

import UIKit

/// 等待对方接听的三点 loading
final class EP_WaitingDotsView: UIView {

    private let dotViews: [UIView] = (0..<3).map { _ in UIView() }
    private var isAnimating = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        dotViews.forEach { dot in
            dot.backgroundColor = .white
            dot.layer.cornerRadius = 4
            addSubview(dot)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let dotSize: CGFloat = 8
        let spacing: CGFloat = 8
        let totalWidth = dotSize * 3 + spacing * 2
        var x = (bounds.width - totalWidth) / 2
        let y = (bounds.height - dotSize) / 2
        for dot in dotViews {
            dot.frame = CGRect(x: x, y: y, width: dotSize, height: dotSize)
            x += dotSize + spacing
        }
    }

    func startAnimating() {
        guard !isAnimating else { return }
        isAnimating = true
        for (index, dot) in dotViews.enumerated() {
            dot.alpha = 0.35
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.fromValue = 0.35
            animation.toValue = 1
            animation.duration = 0.55
            animation.beginTime = CACurrentMediaTime() + Double(index) * 0.18
            animation.autoreverses = true
            animation.repeatCount = .infinity
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            dot.layer.add(animation, forKey: "pulse")
        }
    }

    func stopAnimating() {
        isAnimating = false
        dotViews.forEach { $0.layer.removeAllAnimations() }
    }
}
