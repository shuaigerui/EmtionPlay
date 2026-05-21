//
//  EP_UserListCell.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/20.
//

import UIKit

struct EP_UserListItem {
    let userId: String
    let avatarImageName: String
    let userName: String
    /// 当前登录用户是否已关注该用户
    let isFollowing: Bool

    init(userId: String, avatarImageName: String, userName: String, isFollowing: Bool = false) {
        self.userId = userId
        self.avatarImageName = avatarImageName
        self.userName = userName
        self.isFollowing = isFollowing
    }
}

enum EP_UserListMode {
    case black
    case fan
    case follow

    var titleImageName: String {
        switch self {
        case .black: return "black_title"
        case .fan: return "fan_title"
        case .follow: return "follow_title"
        }
    }

    func actionButtonImageName(isFollowing: Bool) -> String {
        switch self {
        case .black: return "black_cancel"
        case .follow: return "follow_follow"
        case .fan: return isFollowing ? "follow_follow" : "fan_follow"
        }
    }
}

final class EP_UserListCell: UICollectionViewCell {

    static let reuseID = "EP_UserListCell"

    var onActionTapped: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(cardView)
        cardView.addSubview(avatarImageView)
        cardView.addSubview(nameLabel)
        cardView.addSubview(actionButton)

        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        avatarImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.centerX.equalToSuperview()
            make.size.equalTo(66)
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(8)
        }

        actionButton.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(63)
        }

        actionButton.addTarget(self, action: #selector(onActionButtonTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let side = min(avatarImageView.bounds.width, avatarImageView.bounds.height)
        avatarImageView.layer.cornerRadius = side / 2
    }

    func configure(with item: EP_UserListItem, mode: EP_UserListMode) {
        avatarImageView.image = item.avatarImageName.toAvatarImage ?? item.avatarImageName.toImage
        nameLabel.text = item.userName
        let imageName = mode.actionButtonImageName(isFollowing: item.isFollowing)
        actionButton.setImage(imageName.toImage, for: .normal)
    }

    @objc private func onActionButtonTapped() {
        onActionTapped?()
    }

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = "#F5F3FF".toColor
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()

    private let avatarImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 33
        view.layer.masksToBounds = true
        return view
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()

    private let actionButton: UIButton = {
        let button = UIButton(type: .custom)
        return button
    }()
}
