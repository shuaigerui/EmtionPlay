//
//  EP_UserListVC.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/20.
//

import UIKit

class EP_UserListVC: EP_BaseVC {

    private let mode: EP_UserListMode
    private var users: [EP_UserListItem]

    init(mode: EP_UserListMode) {
        self.mode = mode
        self.users = Self.defaultItems
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        titleView.image = mode.titleImageName.toImage
        setupUI()
        setupConstraints()
        setupEvents()
    }

    private func setupUI() {
        view.addSubview(backButton)
        view.addSubview(titleView)
        view.addSubview(collectionView)
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

        collectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(backButton.snp.bottom).offset(18)
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

        let cellWidth = (view.frame.width - 48) / 2
        return CGSize(width: cellWidth, height: 195)
    }

    private func handleAction(at index: Int) {
        guard users.indices.contains(index) else { return }
        switch mode {
        case .black:
            users.remove(at: index)
            collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
        case .fan, .follow:
            break
        }
    }

    private let backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("common_back".toImage, for: .normal)
        return button
    }()

    private let titleView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 14
        layout.sectionInset = UIEdgeInsets(
            top: 0,
            left: 16,
            bottom: 16,
            right: 16
        )

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(EP_UserListCell.self, forCellWithReuseIdentifier: EP_UserListCell.reuseID)
        return collectionView
    }()

    private static let defaultItems: [EP_UserListItem] = [
        EP_UserListItem(avatarImageName: "home_top", userName: "Marceline"),
        EP_UserListItem(avatarImageName: "home_top", userName: "Marceline"),
        EP_UserListItem(avatarImageName: "home_top", userName: "Marceline"),
        EP_UserListItem(avatarImageName: "home_top", userName: "Marceline"),
        EP_UserListItem(avatarImageName: "home_top", userName: "Marceline"),
        EP_UserListItem(avatarImageName: "home_top", userName: "Marceline"),
    ]
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegateFlowLayout

extension EP_UserListVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        users.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: EP_UserListCell.reuseID,
            for: indexPath
        ) as? EP_UserListCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: users[indexPath.item], mode: mode)
        cell.onActionTapped = { [weak self] in
            self?.handleAction(at: indexPath.item)
        }
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
