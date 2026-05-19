//
//  EP_ChatRoomVC.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/19.
//

import UIKit

class EP_ChatRoomVC: EP_BaseVC {

    private enum Layout {
        static let headerHeight: CGFloat = 155
        static let inputBarHeight: CGFloat = 64
    }

    private let peerName: String
    private let peerAvatarImageName: String
    private var messages: [EP_RoomMessageItem]

    init(
        peerName: String = "Beach",
        peerAvatarImageName: String = "home_top",
        messages: [EP_RoomMessageItem] = EP_ChatRoomVC.defaultMessages
    ) {
        self.peerName = peerName
        self.peerAvatarImageName = peerAvatarImageName
        self.messages = messages
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    convenience init(chatItem: EP_ChatMessageItem) {
        self.init(
            peerName: chatItem.userName,
            peerAvatarImageName: chatItem.avatarImageName,
            messages: [
                EP_RoomMessageItem(
                    kind: .incoming,
                    text: chatItem.message,
                    avatarImageName: chatItem.avatarImageName
                ),
            ]
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
        tableView.tableHeaderView = header
    }

    private func updateTableHeaderLayoutIfNeeded() {
        guard let header = tableView.tableHeaderView else { return }
        let width = tableView.bounds.width
        guard width > 0, header.frame.width != width || header.frame.height != Layout.headerHeight else { return }
        header.frame = CGRect(x: 0, y: 0, width: width, height: Layout.headerHeight)
        tableView.tableHeaderView = header
    }

    private func appendOutgoingMessage(_ text: String) {
        let item = EP_RoomMessageItem(
            kind: .outgoing,
            text: text,
            avatarImageName: "home_top"
        )
        messages.append(item)
        tableView.reloadData()
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

    private static let defaultMessages: [EP_RoomMessageItem] = [
        EP_RoomMessageItem(
            kind: .incoming,
            text: "Hello. What do I need your answerHello. What do I need your answer?",
            avatarImageName: "home_top"
        ),
        EP_RoomMessageItem(
            kind: .outgoing,
            text: "Hello. What do I need your answerHello. What do I need your answer?",
            avatarImageName: "home_top"
        ),
    ]

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
