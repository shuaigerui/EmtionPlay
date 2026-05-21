//
//  EP_GroupRoomVC.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/21.
//

import UIKit

class EP_GroupRoomVC: EP_BaseVC {

    private enum Layout {
        static let inputBarHeight: CGFloat = 64
        static let topActionSize: CGFloat = 44
        static let headerHeight = EP_GroupRoomHeaderView.preferredHeight
    }

    private static let welcomeTemplate =
        "Welcome to %@, please use the civilized language, release any vulgar, fraudulent, illegal Information will be banned account."

    private let room: EP_RoomItem

    private var welcomeText: String {
        String(format: Self.welcomeTemplate, room.name)
    }

    /// 进入房间后随机展示的成员欢迎语（仅内存，不持久化）
    private static let welcomeScripts: [String] = [
        "Hey everyone! Glad to join the group!",
        "Hi all! Excited to chat with you today.",
        "Hello! Nice to meet everyone here.",
        "Welcome me in — happy to be part of this room!",
        "Hey! Looking forward to some fun conversations.",
        "Hi! Hope everyone is having a great day.",
        "Hello friends! Ready for a good chat?",
        "So happy to find this group — let's talk!",
        "Hey there! Anyone want to share what they're up to?",
        "Hi! Just joined — say hi if you see this!",
        "Hello everyone! What's the vibe in here today?",
        "Great to be here! Feel free to introduce yourselves.",
        "Hey! I love this topic — can't wait to discuss.",
        "Hi all! Any recommendations for newcomers?",
        "Hello! Let's keep things friendly and fun.",
        "Nice room! Happy to hang out with you all.",
        "Hey everyone! Who's online right now?",
        "Hi! Dropping in to say hello to the group.",
        "Hello! Hope we can all get along and chat more.",
        "Glad I joined — looking forward to meeting you!",
    ]

    private static let welcomeMemberNames = [
        "Victoria", "Emma", "Sophia", "Chloe", "Mia", "Lily", "Grace", "Zoe",
    ]

    private var messages: [EP_GroupMessageItem] = []
    private var isPageActive = false
    private var welcomeWorkItem: DispatchWorkItem?

    init(room: EP_RoomItem) {
        self.room = room
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
        seedMessages()

        setupUI()
        setupConstraints()
        setupEvents()
        setupTableHeader()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isPageActive = true
        tableView.reloadData()
        scheduleWelcomeMessage()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isPageActive = false
        welcomeWorkItem?.cancel()
        welcomeWorkItem = nil
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeaderLayoutIfNeeded()
    }

    private func seedMessages() {
        messages = [
            EP_GroupMessageItem(kind: .system, text: welcomeText),
        ]
    }

    private func scheduleWelcomeMessage() {
        welcomeWorkItem?.cancel()
        let delay = Double.random(in: 1...4)
        let work = DispatchWorkItem { [weak self] in
            self?.appendRandomWelcomeMessage()
        }
        welcomeWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: work)
    }

    private func appendRandomWelcomeMessage() {
        guard isPageActive,
              let text = Self.welcomeScripts.randomElement(),
              let userName = Self.welcomeMemberNames.randomElement() else { return }
        messages.append(EP_GroupMessageItem(kind: .member(userName: userName), text: text))
        tableView.reloadData()
        scrollToBottom(animated: true)
    }

    private func setupUI() {
        view.addSubview(bgV)
        view.addSubview(tableView)
        view.addSubview(inputBarView)
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(alertButton)
        view.addSubview(outButton)
        view.bringSubviewToFront(backButton)
        view.bringSubviewToFront(titleLabel)
        view.bringSubviewToFront(alertButton)
        view.bringSubviewToFront(outButton)

        inputBarView.backgroundColor = .clear
    }

    private func setupConstraints() {
        bgV.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.size.equalTo(Layout.topActionSize)
        }

        outButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(titleLabel)
            make.size.equalTo(Layout.topActionSize)
        }

        alertButton.snp.makeConstraints { make in
            make.trailing.equalTo(outButton.snp.leading).offset(-10)
            make.centerY.equalTo(titleLabel)
            make.size.equalTo(Layout.topActionSize)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(backButton.snp.bottom).offset(4)
            make.trailing.lessThanOrEqualTo(alertButton.snp.leading).offset(-12)
        }

        inputBarView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(Layout.inputBarHeight)
        }

        tableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.bottom.equalTo(inputBarView.snp.top)
        }
    }

    private func setupEvents() {
        backButton.addTarget(self, action: #selector(clickBackButton), for: .touchUpInside)
        alertButton.addTarget(self, action: #selector(onAlertTapped), for: .touchUpInside)
        outButton.addTarget(self, action: #selector(onOutTapped), for: .touchUpInside)
        inputBarView.onSendTapped = { [weak self] text in
            self?.appendOutgoingMessage(text)
        }
    }

    private func setupTableHeader() {
        let header = EP_GroupRoomHeaderView(
            frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: Layout.headerHeight)
        )
        header.configure(
            coverImageName: room.coverImageName,
            memberAvatarImageNames: room.memberAvatarImageNames
        )
        tableView.tableHeaderView = header
    }

    private func updateTableHeaderLayoutIfNeeded() {
        guard let header = tableView.tableHeaderView else { return }
        let width = tableView.bounds.width
        guard width > 0, header.frame.size != CGSize(width: width, height: Layout.headerHeight) else { return }
        header.frame = CGRect(x: 0, y: 0, width: width, height: Layout.headerHeight)
        tableView.tableHeaderView = header
    }

    private func appendOutgoingMessage(_ text: String) {
        let name = EP_CurrentUser.shared.user?.name ?? "Me"
        messages.append(EP_GroupMessageItem(kind: .member(userName: name), text: text))
        tableView.reloadData()
        scrollToBottom(animated: true)
    }

    private func scrollToBottom(animated: Bool) {
        guard !messages.isEmpty else { return }
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
    }

    @objc private func clickBackButton() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func onAlertTapped() {
        let alert = UIAlertController(
            title: "Community Guidelines",
            message: welcomeText,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func onOutTapped() {
        let alert = UIAlertController(
            title: "Leave Group",
            message: "Are you sure you want to leave this group chat?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Leave", style: .destructive) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.estimatedRowHeight = 72
        tableView.rowHeight = UITableView.automaticDimension
        tableView.keyboardDismissMode = .onDrag
        tableView.dataSource = self
        tableView.register(
            EP_GroupMessageCell.self,
            forCellReuseIdentifier: EP_GroupMessageCell.reuseID
        )
        return tableView
    }()

    private let inputBarView = EP_DetailInputView()

    private let bgV: UIImageView = {
        let view = UIImageView()
        view.image = "group_bg".toImage
        view.contentMode = .scaleAspectFill
        return view
    }()

    private let backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("common_back".toImage, for: .normal)
        return button
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = room.name
        label.textColor = .white
        if let descriptor = UIFont.systemFont(ofSize: 28, weight: .bold).fontDescriptor
            .withSymbolicTraits([.traitBold, .traitItalic]) {
            label.font = UIFont(descriptor: descriptor, size: 28)
        } else {
            label.font = .systemFont(ofSize: 28, weight: .bold)
        }
        label.numberOfLines = 2
        return label
    }()

    private let alertButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("group_alert".toImage, for: .normal)
        return button
    }()

    private let outButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("group_out".toImage, for: .normal)
        return button
    }()
}

// MARK: - UITableViewDataSource

extension EP_GroupRoomVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: EP_GroupMessageCell.reuseID,
            for: indexPath
        ) as? EP_GroupMessageCell else {
            return UITableViewCell()
        }
        cell.configure(with: messages[indexPath.row])
        return cell
    }
}
