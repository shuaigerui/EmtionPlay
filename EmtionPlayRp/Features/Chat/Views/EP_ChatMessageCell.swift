//
//  EP_ChatMessageCell.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/19.
//

import UIKit

struct EP_ChatMessageItem {
    let avatarImageName: String
    let userName: String
    let dateText: String
    let message: String
    var hasUnread: Bool
}

final class EP_ChatMessageCell: UITableViewCell {

    static let reuseID = "EP_ChatMessageCell"

    private enum Layout {
        static let cardCornerRadius: CGFloat = 16
        static let horizontalInset: CGFloat = 16
        static let verticalInset: CGFloat = 5
        static let cardPadding: CGFloat = 14
        static let avatarSize: CGFloat = 48
        static let nameDateSpacing: CGFloat = 8
        static let messageTopSpacing: CGFloat = 6
        static let unreadDotSize: CGFloat = 8
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(cardView)
        cardView.addSubview(avatarImageView)
        cardView.addSubview(nameLabel)
        cardView.addSubview(dateLabel)
        cardView.addSubview(messageLabel)
        cardView.addSubview(unreadDotView)

        cardView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(Layout.verticalInset)
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
        }

        avatarImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(Layout.cardPadding)
            make.centerY.equalToSuperview()
            make.size.equalTo(Layout.avatarSize)
        }

        dateLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Layout.cardPadding)
            make.top.equalTo(avatarImageView)
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarImageView.snp.trailing).offset(Layout.nameDateSpacing)
            make.trailing.lessThanOrEqualTo(dateLabel.snp.leading).offset(-8)
            make.centerY.equalTo(dateLabel)
        }

        dateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        unreadDotView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Layout.cardPadding)
            make.centerY.equalTo(messageLabel)
            make.size.equalTo(Layout.unreadDotSize)
        }

        messageLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.trailing.lessThanOrEqualTo(unreadDotView.snp.leading).offset(-8)
            make.top.equalTo(nameLabel.snp.bottom).offset(Layout.messageTopSpacing)
            make.bottom.lessThanOrEqualToSuperview().inset(Layout.cardPadding)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: EP_ChatMessageItem) {
        avatarImageView.image = item.avatarImageName.toImage
        nameLabel.text = item.userName
        dateLabel.text = item.dateText
        messageLabel.text = item.message
        unreadDotView.isHidden = !item.hasUnread
    }

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = Layout.cardCornerRadius
        view.clipsToBounds = true
        return view
    }()

    private let avatarImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = Layout.avatarSize / 2
        return view
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .black
        label.textAlignment = .right
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .black
        label.numberOfLines = 1
        return label
    }()

    private let unreadDotView: UIView = {
        let view = UIView()
        view.backgroundColor = "#FF3B30".toColor
        view.layer.cornerRadius = Layout.unreadDotSize / 2
        view.isHidden = true
        return view
    }()
}
