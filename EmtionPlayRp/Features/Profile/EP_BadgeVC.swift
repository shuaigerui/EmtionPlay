//
//  EP_BadgeVC.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/20.
//

import UIKit

struct EP_BadgeTierItem {
    let title: String
    let value: Int
    let imageName: String
    let lockedImageName: String
    let isUnlocked: Bool
}

class EP_BadgeVC: EP_BaseVC {

    private var remainingCurrent = 0
    private var remainingTotal = EP_BadgeModel.legendThreshold
    private var avatarImageName = ""
    private var badgeTiers: [EP_BadgeTierItem] = []
    private var energyItems: [EP_BadgeEnergyItem] = []
    private var energyRowViews: [EP_BadgeEnergyRowView] = []

    init() {
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        EP_NetworkTool.shared.fetchHuaPl { result in
            switch result {
            case .success(_):
                self.loadData()
            case .failure(_):
                self.loadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupConstraints()
        setupEvents()
    }

    private func loadData() {
        EP_CurrentUser.shared.refreshFromDatabase()
        guard let user = EP_CurrentUser.shared.user else { return }

        let info = user.badgeInfo
        avatarImageName = user.avatar
        remainingCurrent = info.remain
        remainingTotal = EP_BadgeModel.legendThreshold
        badgeTiers = Self.makeBadgeTiers(score: info.remain)
        energyItems = [
            EP_BadgeEnergyItem(
                title: "Publish 10 works",
                current: min(info.push, EP_BadgeModel.pushGoal),
                total: EP_BadgeModel.pushGoal
            ),
            EP_BadgeEnergyItem(
                title: "Received 20 likes",
                current: min(info.receive, EP_BadgeModel.receiveGoal),
                total: EP_BadgeModel.receiveGoal
            ),
            EP_BadgeEnergyItem(
                title: "Gained 10 followers",
                current: min(info.gain, EP_BadgeModel.gainGoal),
                total: EP_BadgeModel.gainGoal
            ),
        ]

        applyData()
        reloadBadgeTiers()
        zip(energyRowViews, energyItems).forEach { row, item in
            row.configure(with: item)
        }
    }

    private static func makeBadgeTiers(score: Int) -> [EP_BadgeTierItem] {
        [
            EP_BadgeTierItem(
                title: "Dimension",
                value: 20,
                imageName: "badge_dimen",
                lockedImageName: "badge_dimen_sel",
                isUnlocked: score >= 20
            ),
            EP_BadgeTierItem(
                title: "Starshine",
                value: 60,
                imageName: "badge_star",
                lockedImageName: "badge_star_sel",
                isUnlocked: score >= 60
            ),
            EP_BadgeTierItem(
                title: "legend",
                value: 100,
                imageName: "badge_legend",
                lockedImageName: "badge_legend_sel",
                isUnlocked: score >= 100
            ),
        ]
    }

    private func reloadBadgeTiers() {
        badgesStack.arrangedSubviews.forEach { view in
            badgesStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        badgeTiers.forEach { tier in
            badgesStack.addArrangedSubview(makeBadgeColumn(for: tier))
        }
    }

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        view.addSubview(backButton)
        view.addSubview(titleView)

        contentStack.addArrangedSubview(statusCardView)
        contentStack.addArrangedSubview(badgesCardView)
        contentStack.addArrangedSubview(energyTitleLabel)
        let rowTitles = [
            "Publish 10 works",
            "Received 20 likes",
            "Gained 10 followers",
        ]
        rowTitles.forEach { _ in
            let row = EP_BadgeEnergyRowView()
            row.snp.makeConstraints { make in
                make.height.equalTo(70)
            }
            energyStack.addArrangedSubview(row)
            energyRowViews.append(row)
        }
        contentStack.addArrangedSubview(energyStack)

        statusCardView.addSubview(avatarImageView)
        statusCardView.addSubview(remainingLabel)
        statusCardView.addSubview(remainingProgressLabel)
        statusCardView.addSubview(remainingProgressView)

        badgesCardView.addSubview(badgesStack)

        contentStack.setCustomSpacing(20, after: badgesCardView)
        contentStack.setCustomSpacing(12, after: energyTitleLabel)
    }

    private func setupConstraints() {
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.size.equalTo(44)
        }

        titleView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backButton)
        }

        scrollView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(backButton.snp.bottom).offset(8)
        }

        contentStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-24)
            make.width.equalTo(scrollView).offset(-32)
        }

        statusCardView.snp.makeConstraints { make in
            make.height.equalTo(146)
        }

        avatarImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.size.equalTo(88)
        }

        remainingLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarImageView.snp.trailing).offset(11)
            make.top.equalToSuperview().offset(29)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(34)
        }

        remainingProgressLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-45)
            make.bottom.equalTo(remainingProgressView.snp.top).offset(-6)
        }

        remainingProgressView.snp.makeConstraints { make in
            make.leading.equalTo(remainingLabel)
            make.trailing.equalToSuperview().offset(-45)
            make.bottom.equalToSuperview().offset(-29)
            make.height.equalTo(13)
        }

        badgesCardView.snp.makeConstraints { make in
            make.height.equalTo(150)
        }

        badgesStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8))
        }
        
        energyTitleLabel.snp.makeConstraints { make in
            make.height.equalTo(28)
        }
    }

    private func setupEvents() {
        backButton.addTarget(self, action: #selector(clickBackButton), for: .touchUpInside)
    }

    private func applyData() {
        avatarImageView.image = avatarImageName.toAvatarImage ?? avatarImageName.toImage
        remainingProgressLabel.text = "\(remainingCurrent)/\(remainingTotal)"
        let progress = remainingTotal > 0
            ? min(1, CGFloat(remainingCurrent) / CGFloat(remainingTotal))
            : 0
        remainingProgressView.progress = progress
    }

    @objc private func clickBackButton() {
        navigationController?.popViewController(animated: true)
    }

    private func makeBadgeColumn(for tier: EP_BadgeTierItem) -> UIView {
        let container = UIView()

        let titleLabel = UILabel()
        titleLabel.text = tier.title
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = "#F1F1F1".toColor
        titleLabel.textAlignment = .center

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = (tier.isUnlocked ? tier.lockedImageName : tier.imageName).toImage

        let valueLabel = UILabel()
        valueLabel.text = "\(tier.value)"
        valueLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        valueLabel.textColor = .white
        valueLabel.textAlignment = .center

        container.addSubview(titleLabel)
        container.addSubview(imageView)
        container.addSubview(valueLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        imageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.width.equalTo(82)
            make.height.equalTo(64)
        }

        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(4)
            make.leading.trailing.bottom.equalToSuperview()
        }

        return container
    }

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()

    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        return stack
    }()

    private let backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("common_back".toImage, for: .normal)
        return button
    }()

    private let titleView: UIImageView = {
        let view = UIImageView()
        view.image = "badge_title".toImage
        view.contentMode = .scaleAspectFit
        return view
    }()

    private let statusCardView: UIView = {
        let view = UIView()
        view.backgroundColor = "#C890F7".toColor
        view.layer.cornerRadius = 64
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        return view
    }()

    private let avatarImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 44
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.masksToBounds = true
        return view
    }()

    private let remainingLabel: UILabel = {
        let label = UILabel()
        label.text = "Remaining"
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textColor = .white
        return label
    }()

    private let remainingProgressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = "#E6C9FF".toColor
        label.textAlignment = .right
        return label
    }()

    private let remainingProgressView = EP_BadgeProgressView()

    private let badgesCardView: UIView = {
        let view = UIView()
        view.backgroundColor = "#C890F7".toColor
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        return view
    }()

    private let badgesStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .fill
        stack.spacing = 4
        return stack
    }()

    private let energyStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 14
        stack.alignment = .fill
        return stack
    }()

    private lazy var energyTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "energy"
        if let descriptor = UIFont.systemFont(ofSize: 22, weight: .bold)
            .fontDescriptor
            .withSymbolicTraits([.traitBold, .traitItalic]) {
            label.font = UIFont(descriptor: descriptor, size: 22)
        } else {
            label.font = .boldSystemFont(ofSize: 22)
        }
        label.textColor = .black
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
}
