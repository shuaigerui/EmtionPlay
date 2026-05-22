//
//  EP_FriendsVC.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/19.
//

import UIKit

class EP_FriendsVC: EP_BaseVC {

    private enum Layout {
        static let rowHeight: CGFloat = 92
    }

    private let mode: EP_FriendListMode
    private var friends: [EP_FriendItem]

    init(mode: EP_FriendListMode) {
        self.mode = mode
        self.friends = []
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

        setupUI()
        setupConstraints()
        setupEvents()
    }
    
    private func loadData() {
        EP_CurrentUser.shared.refreshFromDatabase()
        guard let current = EP_CurrentUser.shared.user else {
            friends = []
            tableView.reloadData()
            return
        }

        let fanSet = Set(current.fanIds)
        let userIds: [String]
        switch mode {
        case .friend:
            userIds = current.followingIds.filter { fanSet.contains($0) }
        case .follow:
            userIds = current.followingIds
        }

        friends = userIds.compactMap { userId in
            guard let user = UserData.shared.user(userId: userId) else { return nil }
            let isMutual = fanSet.contains(userId)
            return EP_FriendItem(
                userId: userId,
                avatarImageName: user.avatar,
                userName: user.name,
                isFollowing: mode == .follow ? isMutual : false
            )
        }
        tableView.reloadData()
    }

    private func setupUI() {
        view.addSubview(backButton)
        view.addSubview(tableView)
    }

    private func setupConstraints() {
        
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.size.equalTo(44)
        }

        tableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(backButton.snp.bottom).offset(8)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private func setupEvents() {
        backButton.addTarget(self, action: #selector(clickBackButton), for: .touchUpInside)
    }

    @objc private func clickBackButton() {
        navigationController?.popViewController(animated: true)
    }

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.rowHeight = Layout.rowHeight
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(EP_FriendCell.self, forCellReuseIdentifier: EP_FriendCell.reuseID)
        return tableView
    }()

    private let backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("common_back".toImage, for: .normal)
        return button
    }()

}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension EP_FriendsVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        friends.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: EP_FriendCell.reuseID,
            for: indexPath
        ) as? EP_FriendCell else {
            return UITableViewCell()
        }
        let item = friends[indexPath.row]
        cell.configure(with: item, mode: mode)
        cell.onChatTapped = { [weak self] in
            self?.openChat(with: item)
        }
        cell.onFollowTapped = { [weak self] in
            self?.toggleFollow(at: indexPath.row)
        }
        return cell
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completion in
            self?.unfollow(at: indexPath.row)
            completion(true)
        }
        deleteAction.image = "chat_del".toImage?.withRenderingMode(.alwaysOriginal)
        deleteAction.backgroundColor = "#FF3B30".toColor
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }

    private func openChat(with item: EP_FriendItem) {
        EP_ChatRoomVC.show(
            from: self,
            peerUserId: item.userId,
            peerName: item.userName,
            peerAvatarImageName: item.avatarImageName
        )
    }

    private func toggleFollow(at index: Int) {
        guard mode == .follow else { return }
        unfollow(at: index)
    }

    private func unfollow(at index: Int) {
        guard friends.indices.contains(index),
              let ownerId = EP_CurrentUser.shared.user?.userId else { return }
        let targetId = friends[index].userId
        UserData.shared.unfollowUser(ownerUserId: ownerId, targetUserId: targetId)
        EP_CurrentUser.shared.refreshFromDatabase()
        loadData()
    }
}
