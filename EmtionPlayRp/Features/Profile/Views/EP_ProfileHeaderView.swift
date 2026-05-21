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
    /// 由帖子 img/video 解析的封面；优先于 coverImageName
    let coverImage: UIImage?
    let avatarImageName: String
    let userName: String
    let friendsCount: Int
    let fanCount: Int
    var selectedTab: EP_ProfileTab

    init(
        coverImageName: String,
        coverImage: UIImage? = nil,
        avatarImageName: String,
        userName: String,
        friendsCount: Int,
        fanCount: Int,
        selectedTab: EP_ProfileTab
    ) {
        self.coverImageName = coverImageName
        self.coverImage = coverImage
        self.avatarImageName = avatarImageName
        self.userName = userName
        self.friendsCount = friendsCount
        self.fanCount = fanCount
        self.selectedTab = selectedTab
    }

    static let preview = EP_ProfileHeaderModel(
        coverImageName: "post_temp",
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
    var onFriendsTapped: (() -> Void)?
    var onFanTapped: (() -> Void)?

    private var selectedTab: EP_ProfileTab = .release

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.color(hexString: "#FED9FA")

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
            make.bottom.equalTo(safeAreaLayoutGuide.snp.top).offset(180)
        }

        settingButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(safeAreaLayoutGuide).offset(16)
            make.size.equalTo(32)
        }

        avatarImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(18)
            make.top.equalTo(settingButton.snp.bottom).offset(79)
            make.width.height.equalTo(112)
            make.width.equalTo(avatarImageView.snp.height)
        }
        avatarImageView.setContentHuggingPriority(.required, for: .horizontal)
        avatarImageView.setContentHuggingPriority(.required, for: .vertical)
        avatarImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        avatarImageView.setContentCompressionResistancePriority(.required, for: .vertical)

        editButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(settingButton.snp.bottom).offset(135)
            make.size.equalTo(32)
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(140)
            make.centerY.equalTo(editButton).offset(8)
            make.trailing.lessThanOrEqualTo(editButton.snp.leading).offset(-4)
        }

        statsCardView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(avatarImageView.snp.bottom).offset(17)
            make.height.equalTo(76)
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
            make.leading.equalToSuperview().inset(16)
            make.top.equalTo(statsCardView.snp.bottom).offset(25)
            make.height.equalTo(103)
            make.trailing.equalTo(snp.centerX).offset(-3.5)
        }

        achievementButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.width.height.equalTo(shopButton)
            make.leading.equalTo(snp.centerX).offset(3.5)
        }

        tabStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.equalTo(shopButton.snp.bottom).offset(25)
            make.height.equalTo(44)
        }

        releaseTabButton.addTarget(self, action: #selector(onReleaseTabTapped), for: .touchUpInside)
        likeTabButton.addTarget(self, action: #selector(onLikeTabTapped), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(onEditButtonTapped), for: .touchUpInside)
        settingButton.addTarget(self, action: #selector(onSettingButtonTapped), for: .touchUpInside)
        let shopTap = UITapGestureRecognizer(target: self, action: #selector(onShopButtonTapped))
        shopButton.addGestureRecognizer(shopTap)
        let achieTap = UITapGestureRecognizer(target: self, action: #selector(onAchievementButtonTapped))
        achievementButton.addGestureRecognizer(achieTap)
        friendsStatView.isUserInteractionEnabled = true
        fanStatView.isUserInteractionEnabled = true
        friendsStatView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(onFriendsStatTapped))
        )
        fanStatView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(onFanStatTapped))
        )

        updateTabAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let side = min(avatarImageView.bounds.width, avatarImageView.bounds.height)
        avatarImageView.layer.cornerRadius = side / 2
    }

    func configure(with model: EP_ProfileHeaderModel) {
        coverImageView.image = model.coverImage ?? model.coverImageName.toImage
        avatarImageView.image = model.avatarImageName.toImage
        nameLabel.text = model.userName
        friendsStatView.configure(count: model.friendsCount, title: "Follow")
        fanStatView.configure(count: model.fanCount, title: "Fan")
        selectedTab = model.selectedTab
        updateTabAppearance()
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

    @objc private func onFriendsStatTapped() {
        onFriendsTapped?()
    }

    @objc private func onFanStatTapped() {
        onFanTapped?()
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
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor.white.cgColor
        return view
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
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
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()

    private let friendsStatView = EP_ProfileStatItemView()
    private let fanStatView = EP_ProfileStatItemView()

    private lazy var shopButton: UIImageView = {
        let v = UIImageView()
        v.image = "profile_shop".toImage
        v.contentMode = .scaleAspectFill
        v.isUserInteractionEnabled = true
        return v
    }()

    private lazy var achievementButton: UIImageView = {
        let v = UIImageView()
        v.image = "profile_achive".toImage
        v.contentMode = .scaleAspectFill
        v.isUserInteractionEnabled = true
        return v
    }()

    private lazy var releaseTabButton = makeTabButton(title: "release")
    private lazy var likeTabButton = makeTabButton(title: "Like")

    private lazy var tabStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [releaseTabButton, likeTabButton])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 25
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
