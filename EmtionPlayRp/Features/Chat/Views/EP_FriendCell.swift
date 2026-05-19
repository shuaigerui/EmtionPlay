//
//  EP_FriendCell.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/19.
//

import UIKit

struct EP_FriendItem {
    let avatarImageName: String
    let userName: String
    var isFollowing: Bool
}

enum EP_FriendListMode {
    case friend
    case follow
}

final class EP_FriendCell: UITableViewCell {

    static let reuseID = "EP_FriendCell"

    var onChatTapped: (() -> Void)?
    var onFollowTapped: (() -> Void)?


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(cardView)
        cardView.addSubview(avatarImageView)
        cardView.addSubview(nameLabel)
        cardView.addSubview(chatButton)
        cardView.addSubview(followButton)

        cardView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(7)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        avatarImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
            make.size.equalTo(48)
        }

        chatButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
            make.width.equalTo(133)
            make.height.equalTo(56)
        }

        followButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
            make.height.equalTo(56)
            make.width.greaterThanOrEqualTo(133)
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarImageView.snp.trailing).offset(9)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(chatButton.snp.leading).offset(-8)
        }

        chatButton.addTarget(self, action: #selector(onChatButtonTapped), for: .touchUpInside)
        followButton.addTarget(self, action: #selector(onFollowButtonTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: EP_FriendItem, mode: EP_FriendListMode) {
        avatarImageView.image = item.avatarImageName.toImage
        nameLabel.text = item.userName

        switch mode {
        case .friend:

            chatButton.isHidden = false
            followButton.isHidden = true
            nameLabel.snp.remakeConstraints { make in
                make.leading.equalTo(avatarImageView.snp.trailing).offset(9)
                make.centerY.equalToSuperview()
                make.trailing.lessThanOrEqualTo(chatButton.snp.leading).offset(-8)
            }
        case .follow:

            chatButton.isHidden = true
            followButton.isHidden = false
            updateFollowButton(isFollowing: item.isFollowing)
            nameLabel.snp.remakeConstraints { make in
                make.leading.equalTo(avatarImageView.snp.trailing).offset(9)
                make.centerY.equalToSuperview()
                make.trailing.lessThanOrEqualTo(followButton.snp.leading).offset(-8)
            }
        }
    }

    private func updateFollowButton(isFollowing: Bool) {
        followButton.isSelected = isFollowing
    }

    @objc private func onChatButtonTapped() {
        onChatTapped?()
    }

    @objc private func onFollowButtonTapped() {
        onFollowTapped?()
    }

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = "#F5F3FF".toColor
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()

    private let avatarImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 24
        view.layer.masksToBounds = true
        return view
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .black
        return label
    }()

    private let chatButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("friend_chat".toImage, for: .normal)
        return button
    }()

    private lazy var followButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("friend_follow".toImage, for: .normal)
        button.setImage("friend_followed".toImage, for: .selected)
        button.isHidden = true
        return button
    }()
}
