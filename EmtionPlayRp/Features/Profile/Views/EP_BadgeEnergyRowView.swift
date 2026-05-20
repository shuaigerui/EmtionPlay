//
//  EP_BadgeEnergyRowView.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/20.
//

import UIKit

struct EP_BadgeEnergyItem {
    let title: String
    let current: Int
    let total: Int

    var progress: CGFloat {
        guard total > 0 else { return 0 }
        return min(1, CGFloat(current) / CGFloat(total))
    }
}

final class EP_BadgeEnergyRowView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = "#C890F7".toColor
        layer.cornerRadius = 24
        clipsToBounds = true

        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(ratioLabel)
        addSubview(progressView)

        iconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.size.equalTo(52)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(progressView.snp.leading).offset(-8)
        }

        ratioLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-11)
            make.bottom.equalTo(progressView.snp.top).offset(-5)
        }

        progressView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-18)
            make.width.equalTo(98)
            make.height.equalTo(7)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: EP_BadgeEnergyItem) {
        titleLabel.text = item.title
        ratioLabel.text = "\(item.current)/\(item.total)"
        progressView.progress = item.progress
    }

    private let iconView: UIImageView = {
        let view = UIImageView()
        view.image = "badge_bubble".toImage
        view.contentMode = .scaleAspectFill
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = "#F1F1F1".toColor
        return label
    }()

    private let ratioLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = "#010101".toColor
        label.textAlignment = .right
        return label
    }()

    private let progressView = EP_BadgeProgressView()
}
