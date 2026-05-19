//
//  EP_RoomMessageCell.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/19.
//

import UIKit

enum EP_RoomMessageKind {
    case incoming
    case outgoing
}

struct EP_RoomMessageItem {
    let kind: EP_RoomMessageKind
    let text: String
    let avatarImageName: String
}

final class EP_RoomMessageCell: UITableViewCell {

    static let reuseID = "EP_RoomMessageCell"

    private enum Layout {
        static let horizontalInset: CGFloat = 16
        static let verticalInset: CGFloat = 8
        static let avatarSize: CGFloat = 36
        static let avatarBubbleSpacing: CGFloat = 8
        static let bubbleCornerRadius: CGFloat = 16
        static let bubblePadding = UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 14)
        static let maxBubbleWidthRatio: CGFloat = 0.72
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(avatarImageView)
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.snp.removeConstraints()
        bubbleView.snp.removeConstraints()
    }

    func configure(with item: EP_RoomMessageItem) {
        messageLabel.text = item.text
        avatarImageView.image = item.avatarImageName.toImage

        avatarImageView.snp.remakeConstraints { make in
            make.size.equalTo(Layout.avatarSize)
            make.top.equalToSuperview().inset(Layout.verticalInset)
            switch item.kind {
            case .incoming:
                make.leading.equalToSuperview().inset(Layout.horizontalInset)
            case .outgoing:
                make.trailing.equalToSuperview().inset(Layout.horizontalInset)
            }
        }

        bubbleView.snp.remakeConstraints { make in
            make.top.equalTo(avatarImageView)
            make.bottom.equalToSuperview().inset(Layout.verticalInset)
            make.width.lessThanOrEqualTo(contentView.snp.width).multipliedBy(Layout.maxBubbleWidthRatio)
            switch item.kind {
            case .incoming:
                make.leading.equalTo(avatarImageView.snp.trailing).offset(Layout.avatarBubbleSpacing)
                make.trailing.lessThanOrEqualToSuperview().inset(Layout.horizontalInset)
            case .outgoing:
                make.trailing.equalTo(avatarImageView.snp.leading).offset(-Layout.avatarBubbleSpacing)
                make.leading.greaterThanOrEqualToSuperview().inset(Layout.horizontalInset)
            }
        }

        messageLabel.snp.remakeConstraints { make in
            make.edges.equalToSuperview().inset(Layout.bubblePadding)
        }
    }

    private let avatarImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = Layout.avatarSize / 2
        view.clipsToBounds = true
        return view
    }()

    private let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = "#B8A4F5".toColor
        view.layer.cornerRadius = Layout.bubbleCornerRadius
        view.clipsToBounds = true
        return view
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
}
