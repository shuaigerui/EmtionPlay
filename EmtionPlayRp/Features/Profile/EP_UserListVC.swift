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
        self.users = []
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

        titleView.image = mode.titleImageName.toImage
        setupUI()
        setupConstraints()
        setupEvents()
    }
    
    private func loadData() {
        EP_CurrentUser.shared.refreshFromDatabase()
        guard let currentUser = EP_CurrentUser.shared.user else {
            users = []
            emptyV.isHidden = users.count > 0
            collectionView.reloadData()
            return
        }

        let listUsers: [EP_UserModel]
        switch mode {
        case .follow:
            listUsers = UserData.shared.followingUsers(for: currentUser.userId)
        case .fan:
            listUsers = UserData.shared.fanUsers(for: currentUser.userId)
        case .black:
            listUsers = UserData.shared.blockedUsers(for: currentUser.userId)
        }

        let followingIds = Set(currentUser.followingIds)
        users = listUsers.map {
            EP_UserListItem(
                userId: $0.userId,
                avatarImageName: $0.avatar,
                userName: $0.name,
                isFollowing: followingIds.contains($0.userId)
            )
        }
        emptyV.isHidden = users.count > 0
        collectionView.reloadData()
    }

    private func setupUI() {
        view.addSubview(backButton)
        view.addSubview(titleView)
        view.addSubview(collectionView)
        view.addSubview(emptyV)
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
        
        emptyV.snp.makeConstraints { make in
            make.center.equalToSuperview()
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
        guard users.indices.contains(index),
              let currentUserId = EP_CurrentUser.shared.user?.userId else { return }
        let targetUserId = users[index].userId
        guard !targetUserId.isEmpty else { return }

        switch mode {
        case .black:
            UserData.shared.setUserBlock(
                userId: targetUserId,
                isBlock: false,
                ownerUserId: currentUserId
            )
            EP_CurrentUser.shared.refreshFromDatabase()
            loadData()
        case .follow:
            UserData.shared.unfollowUser(ownerUserId: currentUserId, targetUserId: targetUserId)
            EP_CurrentUser.shared.refreshFromDatabase()
            loadData()
        case .fan:
            if UserData.shared.isFollowing(ownerUserId: currentUserId, targetUserId: targetUserId) {
                UserData.shared.unfollowUser(ownerUserId: currentUserId, targetUserId: targetUserId)
            } else {
                UserData.shared.followUser(ownerUserId: currentUserId, targetUserId: targetUserId)
            }
            EP_CurrentUser.shared.refreshFromDatabase()
            loadData()
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
    
    private var emptyV = EP_EmptyView()

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
