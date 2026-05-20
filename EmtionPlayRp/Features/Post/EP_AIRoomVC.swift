//
//  EP_AIRoomVC.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/20.
//

import UIKit

class EP_AIRoomVC: EP_BaseVC {

    private enum Layout {
        static let inputBarHeight: CGFloat = 64
        static let pinkAreaHeight: CGFloat = 120
        static let aiIconSize: CGFloat = 120
        static let chatCornerRadius: CGFloat = 28
        static let headerHeight: CGFloat = EP_AIHeaderView.preferredHeight
    }

    private var messages: [EP_RoomMessageItem] = [
        EP_RoomMessageItem(
            kind: .incoming,
            text: "Hello. What do I need your answerHello. What do I need your answer?",
            avatarImageName: "ai_icon"
        ),
        EP_RoomMessageItem(
            kind: .outgoing,
            text: "Hello. What do I need your answerHello. What do I need your answer?",
            avatarImageName: "home_top"
        ),
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

        setupUI()
        setupConstraints()
        setupEvents()
        setupTableHeader()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeaderLayoutIfNeeded()
        chatPanelView.layer.cornerRadius = Layout.chatCornerRadius
        chatPanelView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }

    private func setupUI() {
        view.addSubview(pinkHeaderView)
        view.addSubview(chatPanelView)
        chatPanelView.addSubview(tableView)
        view.addSubview(aiIconView)
        view.addSubview(inputBarView)
        view.addSubview(backButton)
        view.addSubview(titleView)
        view.bringSubviewToFront(backButton)
        view.bringSubviewToFront(titleView)
        view.bringSubviewToFront(aiIconView)
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

        pinkHeaderView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(chatPanelView.snp.top).offset(Layout.aiIconSize / 2)
        }

        aiIconView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(chatPanelView.snp.top)
            make.size.equalTo(Layout.aiIconSize)
        }

        chatPanelView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(backButton.snp.bottom).offset(Layout.pinkAreaHeight)
            make.bottom.equalTo(inputBarView.snp.top)
        }

        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        inputBarView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(Layout.inputBarHeight)
        }
    }

    private func setupEvents() {
        backButton.addTarget(self, action: #selector(clickBackButton), for: .touchUpInside)
        inputBarView.onSendTapped = { [weak self] text in
            self?.appendOutgoingMessage(text)
        }
    }

    private func setupTableHeader() {
        let header = EP_AIHeaderView(
            frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: Layout.headerHeight)
        )
        tableView.tableHeaderView = header
    }

    private func updateTableHeaderLayoutIfNeeded() {
        guard let header = tableView.tableHeaderView as? EP_AIHeaderView else { return }
        let width = tableView.bounds.width
        guard width > 0, header.frame.size != CGSize(width: width, height: Layout.headerHeight) else { return }
        header.frame = CGRect(x: 0, y: 0, width: width, height: Layout.headerHeight)
        tableView.tableHeaderView = header
    }

    private func appendOutgoingMessage(_ text: String) {
        messages.append(
            EP_RoomMessageItem(kind: .outgoing, text: text, avatarImageName: "home_top")
        )
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

    private let pinkHeaderView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.color(hexString: "#FED9FA")
        return view
    }()

    private let chatPanelView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.clipsToBounds = true
        return view
    }()

    private let aiIconView: UIImageView = {
        let view = UIImageView()
        view.image = "ai_icon".toImage
        view.contentMode = .scaleAspectFit
        return view
    }()

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

    private let titleView: UIImageView = {
        let view = UIImageView()
        view.image = "ai_title".toImage
        view.contentMode = .scaleAspectFit
        return view
    }()
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension EP_AIRoomVC: UITableViewDataSource, UITableViewDelegate {

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
        cell.configureForAI(with: messages[indexPath.row])
        return cell
    }
}
