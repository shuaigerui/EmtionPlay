//
//  EP_AIHeaderView.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/20.
//

import UIKit

final class EP_AIHeaderView: UIView {

    static let preferredHeight: CGFloat = 200

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear

        addSubview(hintLabel)
        hintLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(88)
            make.leading.trailing.equalToSuperview().inset(24)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let hintLabel: UILabel = {
        let label = UILabel()
        label.text = "Unlocking dynamic posting costs 10 gold coins."
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = "#AAAAAA".toColor
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
}
