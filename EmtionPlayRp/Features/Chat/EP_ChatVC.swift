//
//  EP_ChatVC.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/18.
//

import UIKit

class EP_ChatVC: EP_BaseVC {

    private enum Layout {
        static let rowHeight: CGFloat = 96
    }

    private var messages: [EP_ChatMessageItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        bgView.isHidden = true

        setupUI()
        setupConstraints()
        setupEvents()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }

    private func loadData() {
        EP_CurrentUser.shared.refreshFromDatabase()
        guard let ownerId = EP_CurrentUser.shared.user?.userId else {
            messages = []
            tableView.reloadData()
            return
        }
        EP_ChatStore.shared.reload()
        messages = EP_ChatStore.shared.listItems(ownerUserId: ownerId)
        emptyV.isHidden = messages.count > 0
        tableView.reloadData()
    }

    private func setupEvents() {
        friendButton.addTarget(self, action: #selector(onFriendButtonTapped), for: .touchUpInside)
        followButton.addTarget(self, action: #selector(onFollowButtonTapped), for: .touchUpInside)
    }

    @objc private func onFriendButtonTapped() {
        navigationController?.pushViewController(EP_FriendsVC(mode: .friend), animated: true)
    }

    @objc private func onFollowButtonTapped() {
        navigationController?.pushViewController(EP_FriendsVC(mode: .follow), animated: true)
    }

    private func setupUI() {
        view.addSubview(bgV)
        view.addSubview(titleView)
        view.addSubview(friendButton)
        view.addSubview(followButton)
        view.addSubview(inforView)
        view.addSubview(tableView)
        view.addSubview(emptyV)
    }

    private func setupConstraints() {
        bgV.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
        }

        friendButton.snp.makeConstraints { make in
            make.trailing.equalTo(view.snp.centerX).offset(-33)
            make.top.equalTo(titleView.snp.bottom).offset(22)
        }

        followButton.snp.makeConstraints { make in
            make.leading.equalTo(view.snp.centerX).offset(33)
            make.centerY.equalTo(friendButton)
        }

        inforView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(friendButton.snp.bottom).offset(15)
        }

        tableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(inforView.snp.bottom).offset(12)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        emptyV.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(inforView.snp.bottom).offset(100)
        }
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
        tableView.register(EP_ChatMessageCell.self, forCellReuseIdentifier: EP_ChatMessageCell.reuseID)
        return tableView
    }()

    private let bgV: UIImageView = {
        let view = UIImageView()
        view.image = "bg_02".toImage
        view.contentMode = .scaleAspectFill
        return view
    }()

    private let titleView: UIImageView = {
        let view = UIImageView()
        view.image = "chat_title".toImage
        view.contentMode = .scaleAspectFill
        return view
    }()

    private let friendButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("chat_friend".toImage, for: .normal)
        return button
    }()

    private let followButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("chat_follow".toImage, for: .normal)
        return button
    }()

    private let inforView: UIImageView = {
        let view = UIImageView()
        view.image = "chat_infor".toImage
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private var emptyV = EP_EmptyView()
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension EP_ChatVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: EP_ChatMessageCell.reuseID,
            for: indexPath
        ) as? EP_ChatMessageCell else {
            return UITableViewCell()
        }
        cell.configure(with: messages[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = messages[indexPath.row]
        if item.hasUnread, let ownerId = EP_CurrentUser.shared.user?.userId {
            EP_ChatStore.shared.markAsRead(ownerUserId: ownerId, peerUserId: item.peerUserId)
            messages[indexPath.row].hasUnread = false
            tableView.reloadRows(at: [indexPath], with: .none)
        }
        navigationController?.pushViewController(EP_ChatRoomVC(chatItem: item), animated: true)
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completion in
            guard let self, let ownerId = EP_CurrentUser.shared.user?.userId else {
                completion(false)
                return
            }
            let peerId = self.messages[indexPath.row].peerUserId
            EP_ChatStore.shared.deleteConversation(ownerUserId: ownerId, peerUserId: peerId)
            self.messages.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            completion(true)
        }
        deleteAction.image = swipeDeleteImage()
        deleteAction.backgroundColor = "#FF3B30".toColor
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }

    private func swipeDeleteImage() -> UIImage? {
        guard let image = "chat_del".toImage else { return nil }
        return image.withRenderingMode(.alwaysOriginal)
    }
}
