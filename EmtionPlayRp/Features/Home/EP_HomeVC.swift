//
//  EP_HomeVC.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/18.
//

import UIKit

class EP_HomeVC: EP_BaseVC {

    private enum Layout {
        static let headerHeight: CGFloat = 344
        static let horizontalInset: CGFloat = 16
        static let interitemSpacing: CGFloat = 10
        static let lineSpacing: CGFloat = 10
        static let columnCount: CGFloat = 2
        static let cellAspectRatio: CGFloat = 1.32
    }

    private let feedItems: [EP_HomeFeedItem] = [
        EP_HomeFeedItem(coverImageName: "home_top", avatarImageName: "home_top", userName: "Wren"),
        EP_HomeFeedItem(coverImageName: "home_top", avatarImageName: "home_top", userName: "Milo"),
        EP_HomeFeedItem(coverImageName: "home_top", avatarImageName: "home_top", userName: "Luna"),
        EP_HomeFeedItem(coverImageName: "home_top", avatarImageName: "home_top", userName: "Nova"),
        EP_HomeFeedItem(coverImageName: "home_top", avatarImageName: "home_top", userName: "Iris"),
        EP_HomeFeedItem(coverImageName: "home_top", avatarImageName: "home_top", userName: "Kai"),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        bgView.isHidden = true

        setupUI()
        setupConstraints()
    }

    private func setupUI() {
        view.addSubview(bgV)
        view.addSubview(collectionView)
    }

    private func setupConstraints() {
        bgV.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        collectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }


    private func cellSize(for collectionView: UICollectionView) -> CGSize {
        let width = collectionView.bounds.width > 0
            ? collectionView.bounds.width
            : UIScreen.main.bounds.width
        let totalHorizontalSpacing = Layout.horizontalInset * 2
            + Layout.interitemSpacing * (Layout.columnCount - 1)
        let cellWidth = (width - totalHorizontalSpacing) / Layout.columnCount
        let cellHeight = cellWidth * Layout.cellAspectRatio
        return CGSize(width: cellWidth, height: cellHeight)
    }

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = Layout.interitemSpacing
        layout.minimumLineSpacing = Layout.lineSpacing
        layout.sectionInset = UIEdgeInsets(
            top: 0,
            left: Layout.horizontalInset,
            bottom: Layout.horizontalInset,
            right: Layout.horizontalInset
        )

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(EP_HomeCell.self, forCellWithReuseIdentifier: EP_HomeCell.reuseID)
        collectionView.register(
            EP_HomeHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: EP_HomeHeaderView.reuseID
        )
        return collectionView
    }()

    private let bgV: UIImageView = {
        let view = UIImageView()
        view.image = "bg_02".toImage
        view.contentMode = .scaleAspectFill
        return view
    }()
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegateFlowLayout

extension EP_HomeVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        feedItems.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: EP_HomeCell.reuseID,
            for: indexPath
        ) as? EP_HomeCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: feedItems[indexPath.item])
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: EP_HomeHeaderView.reuseID,
            for: indexPath
        )
        if let headerView = header as? EP_HomeHeaderView {
            headerView.delegate = self
        }
        return header
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: Layout.headerHeight)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        cellSize(for: collectionView)
    }
}

// MARK: - EP_HomeHeaderViewDelegate

extension EP_HomeVC: EP_HomeHeaderViewDelegate {

    func homeHeaderViewDidTapOutfit(_ headerView: EP_HomeHeaderView) {
        navigationController?.pushViewController(EP_ChallengeVC(), animated: true)
    }
}
