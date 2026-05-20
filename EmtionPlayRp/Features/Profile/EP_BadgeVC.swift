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

    private let remainingCurrent: Int = 200
    private let remainingTotal: Int = 300
    private let avatarImageName: String

    private let badgeTiers: [EP_BadgeTierItem] = [
        EP_BadgeTierItem(
            title: "Dimension",
            value: 20,
            imageName: "badge_dimen",
            lockedImageName: "badge_dimen_sel",
            isUnlocked: true
        ),
        EP_BadgeTierItem(
            title: "Starshine",
            value: 60,
            imageName: "badge_star",
            lockedImageName: "badge_star_sel",
            isUnlocked: false
        ),
        EP_BadgeTierItem(
            title: "legend",
            value: 100,
            imageName: "badge_legend",
            lockedImageName: "badge_legend_sel",
            isUnlocked: false
        ),
    ]

    private let energyItems: [EP_BadgeEnergyItem] = [
        EP_BadgeEnergyItem(title: "Publish 10 works", current: 10, total: 10),
        EP_BadgeEnergyItem(title: "Received 20 likes", current: 10, total: 10),
        EP_BadgeEnergyItem(title: "Gained 10 followers", current: 10, total: 10),
    ]

    init(avatarImageName: String = "home_top") {
        self.avatarImageName = avatarImageName
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupConstraints()
        setupEvents()
        applyData()
    }

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        view.addSubview(backButton)
        view.addSubview(titleView)

        contentStack.addArrangedSubview(statusCardView)
        contentStack.addArrangedSubview(badgesCardView)
        contentStack.addArrangedSubview(energyTitleLabel)
        energyItems.forEach { item in
            let row = EP_BadgeEnergyRowView()
            row.configure(with: item)
            row.snp.makeConstraints { make in
                make.height.equalTo(70)
            }
            energyStack.addArrangedSubview(row)
        }
        contentStack.addArrangedSubview(energyStack)

        statusCardView.addSubview(avatarImageView)
        statusCardView.addSubview(remainingLabel)
        statusCardView.addSubview(remainingProgressLabel)
        statusCardView.addSubview(remainingProgressView)

        badgeTiers.forEach { tier in
            badgesStack.addArrangedSubview(makeBadgeColumn(for: tier))
        }
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
        avatarImageView.image = avatarImageName.toImage
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
        imageView.image = (tier.isUnlocked ? tier.imageName : tier.lockedImageName).toImage

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
