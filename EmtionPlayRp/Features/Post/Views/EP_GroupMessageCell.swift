//
//  EP_GroupMessageCell.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/21.
//

import UIKit

enum EP_GroupMessageKind {
    case system
    case member(userName: String)
}

struct EP_GroupMessageItem {
    let kind: EP_GroupMessageKind
    let text: String
}

final class EP_GroupMessageCell: UITableViewCell {

    static let reuseID = "EP_GroupMessageCell"

    private enum Layout {
        static let horizontalInset: CGFloat = 16
        static let verticalInset: CGFloat = 6
        static let bubbleCornerRadius: CGFloat = 16
        static let bubblePadding = UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 14)
        static let systemMaxWidthRatio: CGFloat = 0.92
        static let memberMaxWidthRatio: CGFloat = 0.88
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: EP_GroupMessageItem) {
        bubbleView.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        messageLabel.textColor = .white
        messageLabel.font = .systemFont(ofSize: 15, weight: .regular)

        switch item.kind {
        case .system:
            messageLabel.text = item.text
            messageLabel.textAlignment = .left
            bubbleView.snp.remakeConstraints { make in
                make.top.bottom.equalToSuperview().inset(Layout.verticalInset)
                make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            }
        case .member(let userName):
            messageLabel.text = "\(userName): \(item.text)"
            messageLabel.textAlignment = .left
            bubbleView.snp.remakeConstraints { make in
                make.top.bottom.equalToSuperview().inset(Layout.verticalInset)
                make.leading.equalToSuperview().inset(Layout.horizontalInset)
                make.width.lessThanOrEqualTo(contentView.snp.width).multipliedBy(Layout.memberMaxWidthRatio)
            }
        }

        messageLabel.snp.remakeConstraints { make in
            make.edges.equalToSuperview().inset(Layout.bubblePadding)
        }
    }

    private let bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Layout.bubbleCornerRadius
        view.clipsToBounds = true
        return view
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
}
