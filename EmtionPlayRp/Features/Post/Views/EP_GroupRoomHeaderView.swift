//
//  EP_GroupRoomHeaderView.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/21.
//

import UIKit

final class EP_GroupRoomHeaderView: UIView {

    private enum Layout {
        static let horizontalInset: CGFloat = 16
        static let coverHeight: CGFloat = 260
        static let coverCornerRadius: CGFloat = 12
        static let avatarSize: CGFloat = 78
        static let avatarSpacing: CGFloat = 10
        static let coverToAvatarsSpacing: CGFloat = 12
        static let bottomInset: CGFloat = 8
    }

    static var preferredHeight: CGFloat {
        Layout.coverHeight + Layout.coverToAvatarsSpacing + Layout.avatarSize + Layout.bottomInset
    }

    private var avatarImageNames: [String] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(coverImageView)
        addSubview(avatarCollectionView)

        coverImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.height.equalTo(Layout.coverHeight)
        }

        avatarCollectionView.snp.makeConstraints { make in
            make.top.equalTo(coverImageView.snp.bottom).offset(Layout.coverToAvatarsSpacing)
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.height.equalTo(Layout.avatarSize)
            make.bottom.equalToSuperview().inset(Layout.bottomInset)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(coverImageName: String, memberAvatarImageNames: [String]) {
        coverImageView.image = coverImageName.toImage
        avatarImageNames = memberAvatarImageNames
        avatarCollectionView.reloadData()
    }

    private let coverImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = Layout.coverCornerRadius
        view.clipsToBounds = true
        return view
    }()

    private lazy var avatarCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = Layout.avatarSpacing
        layout.minimumInteritemSpacing = Layout.avatarSpacing

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            EP_GroupMemberAvatarCell.self,
            forCellWithReuseIdentifier: EP_GroupMemberAvatarCell.reuseID
        )
        return collectionView
    }()
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegateFlowLayout

extension EP_GroupRoomHeaderView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        avatarImageNames.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: EP_GroupMemberAvatarCell.reuseID,
            for: indexPath
        ) as? EP_GroupMemberAvatarCell else {
            return UICollectionViewCell()
        }
        cell.configure(imageName: avatarImageNames[indexPath.item])
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(width: Layout.avatarSize, height: Layout.avatarSize)
    }
}

// MARK: - Avatar Cell

private final class EP_GroupMemberAvatarCell: UICollectionViewCell {

    static let reuseID = "EP_GroupMemberAvatarCell"

    private enum Layout {
        static let avatarSize: CGFloat = 78
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(imageName: String) {
        avatarImageView.image = imageName.toAvatarImage ?? imageName.toImage
    }

    private let avatarImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = Layout.avatarSize / 2
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.white.cgColor
        return view
    }()
}
