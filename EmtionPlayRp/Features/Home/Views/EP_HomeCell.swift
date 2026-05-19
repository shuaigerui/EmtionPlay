//
//  EP_HomeCell.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/19.
//

import UIKit

struct EP_HomeFeedItem {
    let coverImageName: String
    let avatarImageName: String
    let userName: String
}

final class EP_HomeCell: UICollectionViewCell {

    static let reuseID = "EP_HomeCell"

    private enum Layout {
        static let cornerRadius: CGFloat = 16
        static let playButtonSize: CGFloat = 32
        static let userInfoInset: CGFloat = 10
        static let avatarSize: CGFloat = 32
        static let avatarNameSpacing: CGFloat = 6
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = Layout.cornerRadius
        contentView.clipsToBounds = true

        contentView.addSubview(coverImageView)
        contentView.addSubview(playImageView)
        contentView.addSubview(userInfoStack)

        coverImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        playImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(Layout.playButtonSize)
        }

        avatarImageView.snp.makeConstraints { make in
            make.size.equalTo(Layout.avatarSize)
        }

        userInfoStack.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview().inset(Layout.userInfoInset)
            make.trailing.lessThanOrEqualToSuperview().inset(Layout.userInfoInset)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: EP_HomeFeedItem) {
        coverImageView.image = item.coverImageName.toImage
        avatarImageView.image = item.avatarImageName.toImage
        nameLabel.text = item.userName
    }

    private let coverImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        return view
    }()

    private let playImageView: UIImageView = {
        let view = UIImageView()
        view.image = "home_play".toImage
        view.contentMode = .scaleAspectFill
        return view
    }()

    private lazy var userInfoStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [avatarImageView, nameLabel])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = Layout.avatarNameSpacing
        return stack
    }()

    private let avatarImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = Layout.avatarSize / 2
        view.layer.masksToBounds = true
        return view
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        return label
    }()
}
