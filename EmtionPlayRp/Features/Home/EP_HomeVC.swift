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

    private var feedItems: [EP_HomeFeedItem] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        bgView.isHidden = true

        setupUI()
        setupConstraints()
    }

    private func loadData() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            UserData.shared.reload()
            let videoPosts = UserData.shared.allVideoPosts
            let items: [EP_HomeFeedItem] = videoPosts.map { post in
                let cover = EP_PostMedia.coverImage(for: post)
                    ?? post.coverImage.toImage
                    ?? UIImage.ep_named("post_temp")
                return EP_HomeFeedItem(post: post, coverImage: cover)
            }
            DispatchQueue.main.async {
                self?.feedItems = items
                self?.collectionView.reloadData()
            }
        }
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let homeItem = feedItems[indexPath.item]
        guard let post = UserData.shared.post(postId: homeItem.postId) else { return }
        let detailVC = EP_DetailVC(post: post)
        navigationController?.pushViewController(detailVC, animated: true)
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
    
    func homeHeaderViewDidPuhlish(_ headerView: EP_HomeHeaderView) {
        navigationController?.pushViewController(EP_ReleaseVC(), animated: true)
    }
}
