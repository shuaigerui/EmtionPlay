//
//  EP_ChatRoomVC.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/19.
//

import Toast_Swift
import UIKit

class EP_ChatRoomVC: EP_BaseVC {

    private enum Layout {
        static let headerHeight: CGFloat = 155
        static let inputBarHeight: CGFloat = 64
    }

    private let peerUserId: String
    private let peerName: String
    private let peerAvatarImageName: String
    private var messages: [EP_RoomMessageItem] = []

    init(peerUserId: String, peerName: String, peerAvatarImageName: String) {
        self.peerUserId = peerUserId
        self.peerName = peerName
        self.peerAvatarImageName = peerAvatarImageName
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    convenience init(peerName: String, peerAvatarImageName: String, peerUserId: String? = nil) {
        self.init(
            peerUserId: EP_ChatConversation.peerId(userId: peerUserId, displayName: peerName),
            peerName: peerName,
            peerAvatarImageName: peerAvatarImageName
        )
    }

    convenience init(chatItem: EP_ChatMessageItem) {
        self.init(
            peerUserId: chatItem.peerUserId,
            peerName: chatItem.userName,
            peerAvatarImageName: chatItem.avatarImageName
        )
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
        setupTableHeader()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadMessages()
        markConversationRead()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeaderLayoutIfNeeded()
    }

    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(inputBarView)
        view.addSubview(backButton)
        view.bringSubviewToFront(backButton)
    }

    private func setupConstraints() {
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.size.equalTo(44)
        }

        inputBarView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(Layout.inputBarHeight)
        }

        tableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(backButton.snp.bottom)
            make.bottom.equalTo(inputBarView.snp.top)
        }
    }

    private func setupEvents() {
        backButton.addTarget(self, action: #selector(clickBackButton), for: .touchUpInside)
        inputBarView.onSendTapped = { [weak self] text in
            self?.appendOutgoingMessage(text)
        }
    }

    private func setupTableHeader() {
        let header = EP_RoomHeaderView(
            frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: Layout.headerHeight)
        )
        header.configure(userName: peerName, avatarImageName: peerAvatarImageName)
        header.moreBlock = { [weak self] in
            self?.presentBlockPeerConfirmation()
        }
        header.videoBlock = { [weak self] in
            guard let self else { return }
            EP_VideoRoomVC.show(
                from: self,
                peerName: self.peerName,
                peerAvatarImageName: self.peerAvatarImageName,
                peerUserId: self.peerUserId
            )
        }
        tableView.tableHeaderView = header
    }

    private func updateTableHeaderLayoutIfNeeded() {
        guard let header = tableView.tableHeaderView else { return }
        let width = tableView.bounds.width
        guard width > 0, header.frame.width != width || header.frame.height != Layout.headerHeight else { return }
        header.frame = CGRect(x: 0, y: 0, width: width, height: Layout.headerHeight)
        tableView.tableHeaderView = header
    }

    private func reloadMessages() {
        guard let ownerId = EP_CurrentUser.shared.user?.userId else {
            messages = []
            tableView.reloadData()
            return
        }
        EP_ChatStore.shared.reload()
        messages = EP_ChatStore.shared.roomMessages(ownerUserId: ownerId, peerUserId: peerUserId)
        tableView.reloadData()
        scrollToBottom(animated: false)
    }

    private func markConversationRead() {
        guard let ownerId = EP_CurrentUser.shared.user?.userId else { return }
        EP_ChatStore.shared.markAsRead(ownerUserId: ownerId, peerUserId: peerUserId)
    }

    private func appendOutgoingMessage(_ text: String) {
        guard let owner = EP_CurrentUser.shared.user else { return }
        let avatar = owner.avatar
        guard EP_ChatStore.shared.appendMessage(
            ownerUserId: owner.userId,
            peerUserId: peerUserId,
            peerName: peerName,
            peerAvatar: peerAvatarImageName,
            text: text,
            isOutgoing: true,
            senderAvatar: avatar
        ) != nil else { return }

        reloadMessages()
        scrollToBottom(animated: true)
    }

    private func scrollToBottom(animated: Bool) {
        guard messages.count > 0 else { return }
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
    }

    @objc private func clickBackButton() {
        navigationController?.popViewController(animated: true)
    }

    private func presentBlockPeerConfirmation() {
        let alert = UIAlertController(
            title: "Block User",
            message: "Block this user and delete all chat history?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Block", style: .destructive) { [weak self] _ in
            self?.blockPeerDeleteChatAndPop()
        })
        present(alert, animated: true)
    }

    private func blockPeerDeleteChatAndPop() {
        guard let ownerId = EP_CurrentUser.shared.user?.userId else { return }

        if UserData.shared.user(userId: peerUserId) != nil {
            ep_blockUser(userId: peerUserId)
        }
        EP_ChatStore.shared.deleteConversation(ownerUserId: ownerId, peerUserId: peerUserId)
        navigationController?.popViewController(animated: true)
    }

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        tableView.keyboardDismissMode = .onDrag
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(EP_RoomMessageCell.self, forCellReuseIdentifier: EP_RoomMessageCell.reuseID)
        return tableView
    }()

    private let inputBarView = EP_DetailInputView()

    private let backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("common_back".toImage, for: .normal)
        return button
    }()
}

// MARK: - UITableViewDataSource

extension EP_ChatRoomVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: EP_RoomMessageCell.reuseID,
            for: indexPath
        ) as? EP_RoomMessageCell else {
            return UITableViewCell()
        }
        cell.configure(with: messages[indexPath.row])
        return cell
    }
}

// MARK: - Entry

extension EP_ChatRoomVC {

    private static let friendsOnlyToast = "You must be friends to start a chat."

    static func show(
        from viewController: UIViewController,
        peerUserId: String,
        peerName: String,
        peerAvatarImageName: String
    ) {
        EP_CurrentUser.shared.refreshFromDatabase()
        guard let ownerId = EP_CurrentUser.shared.user?.userId else { return }
        guard UserData.shared.areMutualFriends(ownerUserId: ownerId, peerUserId: peerUserId) else {
            viewController.view.makeToast(friendsOnlyToast)
            return
        }
        viewController.navigationController?.pushViewController(
            EP_ChatRoomVC(
                peerUserId: peerUserId,
                peerName: peerName,
                peerAvatarImageName: peerAvatarImageName
            ),
            animated: true
        )
    }

    static func show(
        from viewController: UIViewController,
        peerName: String,
        peerAvatarImageName: String,
        peerUserId: String? = nil
    ) {
        let resolvedId = EP_ChatConversation.peerId(userId: peerUserId, displayName: peerName)
        show(
            from: viewController,
            peerUserId: resolvedId,
            peerName: peerName,
            peerAvatarImageName: peerAvatarImageName
        )
    }

    static func show(from viewController: UIViewController, chatItem: EP_ChatMessageItem) {
        show(
            from: viewController,
            peerUserId: chatItem.peerUserId,
            peerName: chatItem.userName,
            peerAvatarImageName: chatItem.avatarImageName
        )
    }
}
