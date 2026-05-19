//
//  EP_ProfileHeaderView.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/19.
//

import UIKit

enum EP_ProfileTab {
    case release
    case like
}

struct EP_ProfileHeaderModel {
    let coverImageName: String
    let avatarImageName: String
    let userName: String
    let friendsCount: Int
    let fanCount: Int
    var selectedTab: EP_ProfileTab

    static let preview = EP_ProfileHeaderModel(
        coverImageName: "home_top",
        avatarImageName: "home_top",
        userName: "Marceline",
        friendsCount: 22,
        fanCount: 22,
        selectedTab: .release
    )
}

final class EP_ProfileHeaderView: UIView {

    var onTabChanged: ((EP_ProfileTab) -> Void)?
    var onEditTapped: (() -> Void)?
    var onSettingTapped: (() -> Void)?
    var onShopTapped: (() -> Void)?
    var onAchievementTapped: (() -> Void)?

    private var selectedTab: EP_ProfileTab = .release

    private enum Layout {
        static let horizontalInset: CGFloat = 16
        static let coverHeight: CGFloat = 220
        static let avatarSize: CGFloat = 96
        static let avatarOverlap: CGFloat = 24
        static let settingButtonSize: CGFloat = 32
        static let editButtonSize: CGFloat = 24
        static let statsHeight: CGFloat = 72
        static let statsCornerRadius: CGFloat = 16
        static let actionButtonHeight: CGFloat = 103
        static let actionButtonSpacing: CGFloat = 10
        static let sectionSpacing: CGFloat = 16
        static let tabSpacing: CGFloat = 24
        static let bottomInset: CGFloat = 12
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.color(hexString: "#F8D4E8")

        addSubview(coverImageView)
        addSubview(settingButton)
        addSubview(avatarImageView)
        addSubview(nameLabel)
        addSubview(editButton)
        addSubview(statsCardView)
        statsCardView.addSubview(friendsStatView)
        statsCardView.addSubview(fanStatView)
        addSubview(shopButton)
        addSubview(achievementButton)
        addSubview(tabStack)

        coverImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(Layout.coverHeight)
        }

        settingButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.top.equalToSuperview().offset(8)
            make.size.equalTo(Layout.settingButtonSize)
        }

        avatarImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(22)
            make.top.equalTo(coverImageView.snp.bottom).offset(-Layout.avatarOverlap)
            make.size.equalTo(Layout.avatarSize)
        }

        editButton.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel.snp.trailing).offset(6)
            make.centerY.equalTo(nameLabel)
            make.size.equalTo(Layout.editButtonSize)
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarImageView.snp.trailing).offset(12)
            make.centerY.equalTo(avatarImageView).offset(8)
            make.trailing.lessThanOrEqualTo(editButton.snp.leading).offset(-4)
        }

        statsCardView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.top.equalTo(avatarImageView.snp.bottom).offset(Layout.sectionSpacing)
            make.height.equalTo(Layout.statsHeight)
        }

        friendsStatView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }

        fanStatView.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }

        shopButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(Layout.horizontalInset)
            make.top.equalTo(statsCardView.snp.bottom).offset(Layout.sectionSpacing)
            make.height.equalTo(Layout.actionButtonHeight)
            make.trailing.equalTo(snp.centerX).offset(-Layout.actionButtonSpacing / 2)
        }

        achievementButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.top.width.height.equalTo(shopButton)
            make.leading.equalTo(snp.centerX).offset(Layout.actionButtonSpacing / 2)
        }

        tabStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(Layout.horizontalInset)
            make.top.equalTo(shopButton.snp.bottom).offset(Layout.sectionSpacing)
            make.bottom.equalToSuperview().inset(Layout.bottomInset)
        }

        releaseTabButton.addTarget(self, action: #selector(onReleaseTabTapped), for: .touchUpInside)
        likeTabButton.addTarget(self, action: #selector(onLikeTabTapped), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(onEditButtonTapped), for: .touchUpInside)
        settingButton.addTarget(self, action: #selector(onSettingButtonTapped), for: .touchUpInside)
        shopButton.addTarget(self, action: #selector(onShopButtonTapped), for: .touchUpInside)
        achievementButton.addTarget(self, action: #selector(onAchievementButtonTapped), for: .touchUpInside)

        updateTabAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with model: EP_ProfileHeaderModel) {
        coverImageView.image = model.coverImageName.toImage
        avatarImageView.image = model.avatarImageName.toImage
        nameLabel.text = model.userName
        friendsStatView.configure(count: model.friendsCount, title: "Friends")
        fanStatView.configure(count: model.fanCount, title: "Fan")
        selectedTab = model.selectedTab
        updateTabAppearance()
    }

    static var preferredHeight: CGFloat {
        Layout.coverHeight
            - Layout.avatarOverlap
            + Layout.avatarSize
            + Layout.sectionSpacing
            + Layout.statsHeight
            + Layout.sectionSpacing
            + Layout.actionButtonHeight
            + Layout.sectionSpacing
            + 32
            + Layout.bottomInset
    }

    @objc private func onReleaseTabTapped() {
        guard selectedTab != .release else { return }
        selectedTab = .release
        updateTabAppearance()
        onTabChanged?(.release)
    }

    @objc private func onLikeTabTapped() {
        guard selectedTab != .like else { return }
        selectedTab = .like
        updateTabAppearance()
        onTabChanged?(.like)
    }

    @objc private func onEditButtonTapped() {
        onEditTapped?()
    }

    @objc private func onSettingButtonTapped() {
        onSettingTapped?()
    }

    @objc private func onShopButtonTapped() {
        onShopTapped?()
    }

    @objc private func onAchievementButtonTapped() {
        onAchievementTapped?()
    }

    private func updateTabAppearance() {
        let releaseSelected = selectedTab == .release
        releaseTabButton.setTitleColor(releaseSelected ? .black : "#AAAAAA".toColor, for: .normal)
        likeTabButton.setTitleColor(releaseSelected ? "#AAAAAA".toColor : .black, for: .normal)
    }

    private func makeTabButton(title: String) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        if let descriptor = UIFont.systemFont(ofSize: 22, weight: .bold)
            .fontDescriptor
            .withSymbolicTraits([.traitBold, .traitItalic]) {
            button.titleLabel?.font = UIFont(descriptor: descriptor, size: 22)
        } else {
            button.titleLabel?.font = .boldSystemFont(ofSize: 22)
        }
        return button
    }

    private let coverImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.backgroundColor = "#E8E8E8".toColor
        return view
    }()

    private let settingButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("profile_setting".toImage, for: .normal)
        return button
    }()

    private let avatarImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = Layout.avatarSize / 2
        view.layer.borderWidth = 4
        view.layer.borderColor = UIColor.white.cgColor
        return view
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .black
        return label
    }()

    private let editButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("profile_edit".toImage, for: .normal)
        return button
    }()

    private let statsCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = Layout.statsCornerRadius
        view.clipsToBounds = true
        return view
    }()

    private let friendsStatView = EP_ProfileStatItemView()
    private let fanStatView = EP_ProfileStatItemView()

    private lazy var shopButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("profile_shop".toImage, for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.clipsToBounds = true
        button.layer.cornerRadius = 16
        return button
    }()

    private lazy var achievementButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("profile_achive".toImage, for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.clipsToBounds = true
        button.layer.cornerRadius = 16
        return button
    }()

    private lazy var releaseTabButton = makeTabButton(title: "release")
    private lazy var likeTabButton = makeTabButton(title: "Like")

    private lazy var tabStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [releaseTabButton, likeTabButton])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = Layout.tabSpacing
        return stack
    }()
}

// MARK: - Stat Item

private final class EP_ProfileStatItemView: UIView {

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
