//
//  EP_PostFeedCell.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/19.
//

import UIKit

struct EP_PostFeedItem {
    let postId: String
    let userId: String
    let coverImageName: String
    let img: String
    let video: String
    let avatarImageName: String
    let userName: String
    let content: String
    var isLiked: Bool

    init(
        postId: String = "",
        userId: String = "",
        coverImageName: String,
        img: String = "",
        video: String = "",
        avatarImageName: String,
        userName: String,
        content: String,
        isLiked: Bool
    ) {
        self.postId = postId
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
    /// 非本人动态：举报等
    var onMoreTapped: (() -> Void)?
    /// 本人动态删除成功后回调（刷新列表）
    var onPostDeleted: (() -> Void)?

    private var postId: String = ""
    private var isOwnPost = false


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
        moreButton.addTarget(self, action: #selector(onMoreButtonTapped), for: .touchUpInside)

        avatarImageView.isUserInteractionEnabled = true
        let avatarTap = UITapGestureRecognizer(target: self, action: #selector(onAvatarTap))
        avatarImageView.addGestureRecognizer(avatarTap)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: EP_PostFeedItem) {
        postId = item.postId
        let currentUserId = EP_CurrentUser.shared.user?.userId ?? ""
        isOwnPost = !item.userId.isEmpty && item.userId == currentUserId

        coverImageView.image = item.resolvedCoverImage ?? item.coverImageName.toImage
        avatarImageView.image = item.avatarImageName.toAvatarImage ?? item.avatarImageName.toImage
        nameLabel.text = item.userName
        contentLabel.text = item.content
        likeButton.isSelected = item.isLiked

        chatButton.isHidden = isOwnPost
        likeButton.isHidden = isOwnPost
    }

    @objc private func onLikeButtonTapped() {
        onLikeTapped?()
    }

    @objc private func onAvatarTap() {
        onAvatarTapped?()
    }

    @objc private func onMoreButtonTapped() {
        if isOwnPost {
            presentDeleteConfirmation()
        } else {
            onMoreTapped?()
        }
    }

    private func presentDeleteConfirmation() {
        guard !postId.isEmpty, let viewController = ep_viewController else { return }
        let alert = UIAlertController(
            title: "Delete Post",
            message: "Are you sure you want to delete this post?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteOwnPost()
        })
        viewController.present(alert, animated: true)
    }

    private func deleteOwnPost() {
        guard !postId.isEmpty, UserData.shared.deletePost(postId: postId) else { return }
        EP_CurrentUser.shared.refreshFromDatabase()
        onPostDeleted?()
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

// MARK: - Responder chain

private extension UIView {
    var ep_viewController: UIViewController? {
        var responder: UIResponder? = self
        while let current = responder {
            if let viewController = current as? UIViewController {
                return viewController
            }
            responder = current.next
        }
        return nil
    }
}
