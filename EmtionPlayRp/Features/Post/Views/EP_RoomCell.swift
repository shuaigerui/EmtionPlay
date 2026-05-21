//
//  EP_RoomCell.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/20.
//

import UIKit

struct EP_RoomItem {
    let roomId: String
    let coverImageName: String
    let name: String
    let memberAvatarImageNames: [String]
}

final class EP_RoomCell: UICollectionViewCell {

    static let reuseID = "EP_RoomCell"

//    var onJoinTapped: (() -> Void)?

    private enum Layout {
        static let cornerRadius: CGFloat = 16
        static let avatarSize: CGFloat = 28
        static let avatarOverlap: CGFloat = 10
        static let joinButtonHeight: CGFloat = 48
        static let bottomInset: CGFloat = 10
        static let horizontalInset: CGFloat = 10
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = Layout.cornerRadius
        contentView.clipsToBounds = true

        contentView.addSubview(coverImageView)
        contentView.addSubview(avatarStackView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(joinButton)

        coverImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        avatarStackView.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.height.equalTo(Layout.avatarSize)
        }

        joinButton.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview().inset(Layout.bottomInset)
            make.height.equalTo(Layout.joinButtonHeight)
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Layout.horizontalInset)
            make.trailing.equalToSuperview().offset(-Layout.horizontalInset)
            make.bottom.equalTo(joinButton.snp.top).offset(-6)
        }

//        joinButton.addTarget(self, action: #selector(onJoinButtonTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: EP_RoomItem) {
        coverImageView.image = item.coverImageName.toImage
        nameLabel.text = item.name
        rebuildAvatarStack(avatarImageNames: item.memberAvatarImageNames)
    }

    private func rebuildAvatarStack(avatarImageNames: [String]) {
        avatarStackView.arrangedSubviews.forEach {
            avatarStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        let names = Array(avatarImageNames.prefix(4))
        for (index, name) in names.enumerated() {
            let avatarView = UIImageView()
            avatarView.contentMode = .scaleAspectFill
            avatarView.clipsToBounds = true
            avatarView.layer.cornerRadius = Layout.avatarSize / 2
            avatarView.layer.borderWidth = 2
            avatarView.layer.borderColor = UIColor.white.cgColor
            avatarView.image = name.toAvatarImage ?? name.toImage
            avatarView.snp.makeConstraints { make in
                make.size.equalTo(Layout.avatarSize)
            }
            avatarStackView.addArrangedSubview(avatarView)
            if index > 0 {
                avatarStackView.setCustomSpacing(-Layout.avatarOverlap, after: avatarStackView.arrangedSubviews[index - 1])
            }
        }
    }

//    @objc private func onJoinButtonTapped() {
//        onJoinTapped?()
//    }

    private let coverImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        return view
    }()

    private let avatarStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 0
        return stack
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        return label
    }()

    private let joinButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("room_join".toImage, for: .normal)
        button.isUserInteractionEnabled = false
        return button
    }()
}
