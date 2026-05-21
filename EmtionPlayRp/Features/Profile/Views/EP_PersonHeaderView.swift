//
//  EP_PersonHeaderView.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/20.
//

import UIKit

struct EP_PersonHeaderModel {
    let coverImageName: String
    let coverImage: UIImage?
    let avatarImageName: String
    let userName: String
    let badgeImageName: String?
    let friendsCount: Int
    let fanCount: Int

    init(
        coverImageName: String,
        coverImage: UIImage? = nil,
        avatarImageName: String,
        userName: String,
        badgeImageName: String? = nil,
        friendsCount: Int,
        fanCount: Int
    ) {
        self.coverImageName = coverImageName
        self.coverImage = coverImage
        self.avatarImageName = avatarImageName
        self.userName = userName
        self.badgeImageName = badgeImageName
        self.friendsCount = friendsCount
        self.fanCount = fanCount
    }

    static let preview = EP_PersonHeaderModel(
        coverImageName: "post_temp",
        avatarImageName: "home_top",
        userName: "StreetStreet",
        friendsCount: 22,
        fanCount: 22
    )
}

final class EP_PersonHeaderView: UIView {

    static let preferredHeight: CGFloat = 670

    var onMoreTapped: (() -> Void)?
    var onFriendsTapped: (() -> Void)?
    var onFanTapped: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.color(hexString: "#FED9FA")

        addSubview(coverImageView)
        addSubview(avatarImageView)
        addSubview(nameLabel)
        addSubview(badgeImageView)
        addSubview(statsCardView)
        statsCardView.addSubview(friendsStatView)
        statsCardView.addSubview(fanStatView)
        addSubview(moreButton)

        coverImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide.snp.top).offset(435)
        }

        moreButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(safeAreaLayoutGuide).offset(16)
            make.size.equalTo(44)
        }

        avatarImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(18)
            make.top.equalTo(moreButton.snp.bottom).offset(345)
            make.width.height.equalTo(98)
        }
//        avatarImageView.setContentHuggingPriority(.required, for: .horizontal)
//        avatarImageView.setContentHuggingPriority(.required, for: .vertical)
//        avatarImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
//        avatarImageView.setContentCompressionResistancePriority(.required, for: .vertical)

        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarImageView.snp.trailing).offset(12)
            make.centerY.equalTo(avatarImageView)
            make.trailing.lessThanOrEqualTo(moreButton.snp.leading).offset(-8)
        }

        badgeImageView.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel.snp.trailing).offset(6)
            make.centerY.equalTo(nameLabel)
            make.width.equalTo(41)
            make.height.equalTo(32)
        }

        statsCardView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(avatarImageView.snp.bottom).offset(12)
            make.height.equalTo(76)
            make.bottom.equalToSuperview().inset(16)
        }

        friendsStatView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }

        fanStatView.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }

        moreButton.addTarget(self, action: #selector(onMoreButtonTapped), for: .touchUpInside)
        friendsStatView.isUserInteractionEnabled = true
        fanStatView.isUserInteractionEnabled = true
        friendsStatView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(onFriendsStatTapped))
        )
        fanStatView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(onFanStatTapped))
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let side = min(avatarImageView.bounds.width, avatarImageView.bounds.height)
        avatarImageView.layer.cornerRadius = side / 2

        coverImageView.layer.cornerRadius = 160
        coverImageView.layer.maskedCorners = [.layerMaxXMaxYCorner]
        coverImageView.clipsToBounds = true
    }

    func configure(with model: EP_PersonHeaderModel) {
        coverImageView.image = model.coverImage ?? model.coverImageName.toImage
        avatarImageView.image = model.avatarImageName.toAvatarImage ?? model.avatarImageName.toImage
        nameLabel.text = model.userName
        if let badgeImageName = model.badgeImageName, let image = badgeImageName.toImage {
            badgeImageView.image = image
            badgeImageView.isHidden = false
        } else {
            badgeImageView.isHidden = true
        }
        friendsStatView.configure(count: model.friendsCount, title: "Friends")
        fanStatView.configure(count: model.fanCount, title: "Fan")
    }

    @objc private func onMoreButtonTapped() {
        onMoreTapped?()
    }

    @objc private func onFriendsStatTapped() {
        onFriendsTapped?()
    }

    @objc private func onFanStatTapped() {
        onFanTapped?()
    }

    private let coverImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.backgroundColor = "#E8E8E8".toColor
        return view
    }()

    private let moreButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("person_more".toImage, for: .normal)
        return button
    }()

    private let avatarImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 49
        view.layer.masksToBounds = true
        return view
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .black
        return label
    }()

    private let badgeImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.isHidden = true
        return view
    }()

    private let statsCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()

    private let friendsStatView = EP_PersonStatItemView()
    private let fanStatView = EP_PersonStatItemView()
}

// MARK: - Stat Item

private final class EP_PersonStatItemView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(countLabel)
        addSubview(titleLabel)
        countLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(14)
        }
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(countLabel.snp.bottom).offset(4)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(count: Int, title: String) {
        countLabel.text = "\(count)"
        titleLabel.text = title
    }

    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .black
        return label
    }()
}
