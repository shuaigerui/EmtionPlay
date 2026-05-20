//
//  EP_PersonHeaderView.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/20.
//

import UIKit

struct EP_PersonHeaderModel {
    let coverImageName: String
    let avatarImageName: String
    let userName: String
    let badgeImageName: String?
    let friendsCount: Int
    let fanCount: Int

    static let preview = EP_PersonHeaderModel(
        coverImageName: "post_temp",
        avatarImageName: "home_top",
        userName: "StreetStreet",
        badgeImageName: nil,
        friendsCount: 22,
        fanCount: 22
    )
}

final class EP_PersonHeaderView: UIView {

    static let preferredHeight: CGFloat = 404

    var onMoreTapped: (() -> Void)?
    var onFriendsTapped: (() -> Void)?
    var onFanTapped: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.color(hexString: "#FED9FA")

        addSubview(coverImageView)
        addSubview(curvePanelView)
        addSubview(avatarImageView)
        addSubview(nameLabel)
        addSubview(badgeImageView)
        addSubview(statsCardView)
        statsCardView.addSubview(friendsStatView)
        statsCardView.addSubview(fanStatView)
        addSubview(moreButton)

        coverImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide.snp.top).offset(180)
        }

        curvePanelView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(108)
        }

        moreButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(safeAreaLayoutGuide).offset(16)
            make.size.equalTo(44)
        }

        avatarImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(18)
            make.top.equalTo(coverImageView.snp.bottom).offset(-56)
            make.width.height.equalTo(112)
            make.width.equalTo(avatarImageView.snp.height)
        }
        avatarImageView.setContentHuggingPriority(.required, for: .horizontal)
        avatarImageView.setContentHuggingPriority(.required, for: .vertical)
        avatarImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        avatarImageView.setContentCompressionResistancePriority(.required, for: .vertical)

        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarImageView.snp.trailing).offset(12)
            make.top.equalTo(avatarImageView.snp.top).offset(36)
            make.trailing.lessThanOrEqualTo(moreButton.snp.leading).offset(-8)
        }

        badgeImageView.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel.snp.trailing).offset(6)
            make.centerY.equalTo(nameLabel)
            make.size.equalTo(28)
        }

        statsCardView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(avatarImageView.snp.bottom).offset(17)
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
    }

    func configure(with model: EP_PersonHeaderModel) {
        coverImageView.image = model.coverImageName.toImage
        avatarImageView.image = model.avatarImageName.toImage
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

    private let curvePanelView = EP_PersonCurvePanelView()

    private let moreButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("person_more".toImage, for: .normal)
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

    private let badgeImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
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

// MARK: - Curve Panel

private final class EP_PersonCurvePanelView: UIView {

    override class var layerClass: AnyClass {
        CAShapeLayer.self
    }

    private var shapeLayer: CAShapeLayer {
        layer as! CAShapeLayer
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        shapeLayer.fillColor = UIColor.color(hexString: "#FED9FA").cgColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        shapeLayer.path = curvedPath(in: bounds)
    }

    private func curvedPath(in rect: CGRect) -> CGPath {
        let path = UIBezierPath()
        let leftTopY = rect.height * 0.12
        let rightTopY: CGFloat = 10
        path.move(to: CGPoint(x: 0, y: leftTopY))
        path.addCurve(
            to: CGPoint(x: rect.width, y: rightTopY),
            controlPoint1: CGPoint(x: rect.width * 0.38, y: 0),
            controlPoint2: CGPoint(x: rect.width * 0.78, y: 2)
        )
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.close()
        return path.cgPath
    }
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
