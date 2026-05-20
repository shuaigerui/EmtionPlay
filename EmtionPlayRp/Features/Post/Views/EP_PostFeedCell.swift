//
//  EP_PostFeedCell.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/19.
//

import UIKit

struct EP_PostFeedItem {
    let userId: String
    let coverImageName: String
    let img: String
    let video: String
    let avatarImageName: String
    let userName: String
    let content: String
    var isLiked: Bool

    init(
        userId: String = "",
        coverImageName: String,
        img: String = "",
        video: String = "",
        avatarImageName: String,
        userName: String,
        content: String,
        isLiked: Bool
    ) {
        self.userId = userId
        self.coverImageName = coverImageName
        self.img = img
        self.video = video
        self.avatarImageName = avatarImageName
        self.userName = userName
        self.content = content
        self.isLiked = isLiked
    }

    var resolvedCoverImage: UIImage? {
        EP_PostMedia.coverImage(img: img, video: video, fallbackCover: coverImageName)
    }
}

final class EP_PostFeedCell: UITableViewCell {

    static let reuseID = "EP_PostFeedCell"

    var onLikeTapped: (() -> Void)?
    var onAvatarTapped: (() -> Void)?


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(coverImageView)
        coverImageView.addSubview(actionStack)
        coverImageView.addSubview(userInfoStack)
        coverImageView.addSubview(contentLabel)

        coverImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-15)
        }

        actionStack.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(10)
            make.top.equalToSuperview().offset(24)
        }

        chatButton.snp.makeConstraints { make in
            make.size.equalTo(44)
        }

        likeButton.snp.makeConstraints { make in
            make.size.equalTo(44)
        }

        moreButton.snp.makeConstraints { make in
            make.size.equalTo(44)
        }

        avatarImageView.snp.makeConstraints { make in
            make.size.equalTo(36)
        }

        userInfoStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(8)
            make.bottom.equalTo(contentLabel.snp.top).offset(-10)
            make.trailing.lessThanOrEqualTo(actionStack.snp.leading).offset(-12)
        }

        contentLabel.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview().inset(8)
            make.trailing.equalToSuperview().offset(-20)
        }

        likeButton.addTarget(self, action: #selector(onLikeButtonTapped), for: .touchUpInside)

        avatarImageView.isUserInteractionEnabled = true
        let avatarTap = UITapGestureRecognizer(target: self, action: #selector(onAvatarTap))
        avatarImageView.addGestureRecognizer(avatarTap)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: EP_PostFeedItem) {
        coverImageView.image = item.resolvedCoverImage ?? item.coverImageName.toImage
        avatarImageView.image = item.avatarImageName.toAvatarImage ?? item.avatarImageName.toImage
        nameLabel.text = item.userName
        contentLabel.text = item.content
        likeButton.isSelected = item.isLiked
    }

    @objc private func onLikeButtonTapped() {
        onLikeTapped?()
    }

    @objc private func onAvatarTap() {
        onAvatarTapped?()
    }

    private let coverImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 24
        view.layer.masksToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }()

    private lazy var actionStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [chatButton, likeButton, moreButton])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 9
        return stack
    }()

    private lazy var chatButton = makeActionButton(imageName: "post_chat")

    private lazy var likeButton: UIButton = {
        let button = makeActionButton(imageName: "home_like")
        button.setImage("home_liked".toImage, for: .selected)
        return button
    }()

    private lazy var moreButton = makeActionButton(imageName: "post_more")

    private lazy var userInfoStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [avatarImageView, nameLabel])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 5
        return stack
    }()

    private let avatarImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 18
        view.layer.masksToBounds = true
        return view
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        return label
    }()

    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()

    private func makeActionButton(imageName: String) -> UIButton {
        let button = UIButton(type: .custom)
        button.setImage(imageName.toImage, for: .normal)
        return button
    }
}
