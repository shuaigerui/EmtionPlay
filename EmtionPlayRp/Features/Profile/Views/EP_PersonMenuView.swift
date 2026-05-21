//
//  EP_PersonMenuView.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/20.
//

import UIKit

/// 他人主页底部操作栏：关注 / 视频 / 聊天
final class EP_PersonMenuView: UIView {

    var onFollowTapped: (() -> Void)?
    var onVideoTapped: (() -> Void)?
    var onChatTapped: (() -> Void)?

    var isFollowing: Bool = false {
        didSet { updateFollowAppearance() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        setupUI()
        setupConstraints()
        setupEvents()
        updateFollowAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(actionStack)
    }

    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(72)
        }

        actionStack.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
            make.height.equalTo(56)
        }

        followButton.snp.makeConstraints { make in
//            make.width.equalTo(133)
            make.height.equalTo(56)
        }
        
        videoButton.snp.makeConstraints { make in
//            make.width.equalTo(52)
            make.height.equalTo(56)
        }

        chatButton.snp.makeConstraints { make in
//            make.width.equalTo(52)
            make.height.equalTo(56)
        }
    }

    private func setupEvents() {
        followButton.addTarget(self, action: #selector(handleFollowTap), for: .touchUpInside)
        videoButton.addTarget(self, action: #selector(handleVideoTap), for: .touchUpInside)
        chatButton.addTarget(self, action: #selector(handleChatTap), for: .touchUpInside)
    }

    private func updateFollowAppearance() {

        followButton.isSelected = isFollowing
    }

    @objc private func handleFollowTap() {
        onFollowTapped?()
    }

    @objc private func handleVideoTap() {
        onVideoTapped?()
    }

    @objc private func handleChatTap() {
        onChatTapped?()
    }

    private let containerView: UIImageView = {
        let view = UIImageView()
        view.image = "person_menuBg".toImage
        view.contentMode = .scaleAspectFill
        view.isUserInteractionEnabled = true
        return view
    }()

    private lazy var actionStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [followButton, videoButton, chatButton])
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()

    private lazy var followButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("fan_follow".toImage, for: .normal)
        button.setImage("follow_follow".toImage, for: .selected)
        return button
    }()

    private lazy var videoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("person_video".toImage, for: .normal)
        return button
    }()

    private lazy var chatButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("person_chat".toImage, for: .normal)
        return button
    }()
}
