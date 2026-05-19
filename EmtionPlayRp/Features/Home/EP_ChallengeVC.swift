//
//  EP_ChallengeVC.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/19.
//

import UIKit

class EP_ChallengeVC: EP_BaseVC {

    private enum Layout {
        static let horizontalInset: CGFloat = 16
        static let interitemSpacing: CGFloat = 10
        static let lineSpacing: CGFloat = 10
        static let columnCount: CGFloat = 2
        static let cellAspectRatio: CGFloat = 1.5
        static let collectionTopSpacing: CGFloat = 16
    }

    private let items: [EP_ChallengeItem] = [
        EP_ChallengeItem(coverImageName: "home_top", likeCount: "1123", caption: "2h makeup, 5min photos."),
        EP_ChallengeItem(coverImageName: "home_top", likeCount: "1123", caption: "2h makeup, 5min photos."),
        EP_ChallengeItem(coverImageName: "home_top", likeCount: "986", caption: "2h makeup, 5min photos."),
        EP_ChallengeItem(coverImageName: "home_top", likeCount: "856", caption: "2h makeup, 5min photos."),
        EP_ChallengeItem(coverImageName: "home_top", likeCount: "743", caption: "2h makeup, 5min photos."),
        EP_ChallengeItem(coverImageName: "home_top", likeCount: "621", caption: "2h makeup, 5min photos."),
    ]

    init() {
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        bgView.isHidden = true

        setupUI()
        setupConstraints()
        setupEvents()
    }

    private func setupUI() {
        view.addSubview(bgV)
        view.addSubview(backButton)
        view.addSubview(titleView)
        view.addSubview(releaseView)
        view.addSubview(fireView)
        view.addSubview(collectionView)
    }

    private func setupConstraints() {
        bgV.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.size.equalTo(44)
        }

        titleView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backButton)
        }

        fireView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(3)
        }

        releaseView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(backButton.snp.bottom).offset(20)
            make.width.equalTo(325)
            make.height.equalTo(130)
        }

        collectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(releaseView.snp.bottom).offset(Layout.collectionTopSpacing)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private func setupEvents() {
        backButton.addTarget(self, action: #selector(clickBackButton), for: .touchUpInside)
    }

    @objc private func clickBackButton() {
        navigationController?.popViewController(animated: true)
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
        collectionView.register(EP_ChallengeCell.self, forCellWithReuseIdentifier: EP_ChallengeCell.reuseID)
        return collectionView
    }()

    private let bgV: UIImageView = {
        let view = UIImageView()
        view.image = "bg_02".toImage
        view.contentMode = .scaleAspectFill
        return view
    }()

    private let backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("common_back".toImage, for: .normal)
        return button
    }()

    private let titleView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.image = "challenge_title".toImage
        return view
    }()

    private let fireView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.image = "challenge_fire".toImage
        return view
    }()

    private let releaseView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.image = "challenge_release".toImage
        return view
    }()
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegateFlowLayout

extension EP_ChallengeVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: EP_ChallengeCell.reuseID,
            for: indexPath
        ) as? EP_ChallengeCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: items[indexPath.item])
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        cellSize(for: collectionView)
    }
}
