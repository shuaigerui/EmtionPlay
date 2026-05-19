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
        self.friends = mode == .follow ? Self.defaultFollowItems : Self.defaultFriendItems
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupConstraints()
        setupEvents()
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

    private static let defaultFriendItems: [EP_FriendItem] = [
        EP_FriendItem(avatarImageName: "home_top", userName: "Marceline", isFollowing: false),
        EP_FriendItem(avatarImageName: "home_top", userName: "Marceline", isFollowing: false),
        EP_FriendItem(avatarImageName: "home_top", userName: "Marceline", isFollowing: false),
        EP_FriendItem(avatarImageName: "home_top", userName: "Marceline", isFollowing: false),
        EP_FriendItem(avatarImageName: "home_top", userName: "Marceline", isFollowing: false),
    ]

    private static let defaultFollowItems: [EP_FriendItem] = [
        EP_FriendItem(avatarImageName: "home_top", userName: "Marceline", isFollowing: false),
        EP_FriendItem(avatarImageName: "home_top", userName: "Marceline", isFollowing: false),
        EP_FriendItem(avatarImageName: "home_top", userName: "Marceline", isFollowing: true),
    ]
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
        cell.configure(with: friends[indexPath.row], mode: mode)
        cell.onChatTapped = {
            // TODO: Open chat with friend
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
            self?.friends.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            completion(true)
        }
        deleteAction.image = "chat_del".toImage?.withRenderingMode(.alwaysOriginal)
        deleteAction.backgroundColor = "#FF3B30".toColor
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }

    private func toggleFollow(at index: Int) {
        guard mode == .follow, friends.indices.contains(index) else { return }
        friends[index].isFollowing.toggle()
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
    }
}
