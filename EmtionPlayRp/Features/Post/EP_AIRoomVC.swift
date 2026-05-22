//
//  EP_AIRoomVC.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/20.
//

import UIKit

class EP_AIRoomVC: EP_BaseVC {

    private static let welcomeText = "Hello, is there anything you'd like to tell me?"

    private static let replyScripts: [String] = [
        "I'm here to listen. Take your time.",
        "Thank you for sharing that with me.",
        "I hear you. How does that make you feel?",
        "That sounds important. Would you like to say more?",
        "You're not alone in this. I'm glad you reached out.",
        "It's okay to feel that way. Your feelings are valid.",
        "Let's take it one step at a time together.",
        "I appreciate you opening up to me.",
        "Sometimes talking helps. Keep going if you'd like.",
        "I'm with you. What happened next?",
    ]

    private var messages: [EP_RoomMessageItem] = [
        EP_RoomMessageItem(
            kind: .incoming,
            text: welcomeText,
            avatarImageName: "ai_icon"
        ),
    ]

    private var isPageActive = false

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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isPageActive = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isPageActive = false
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        chatPanelView.layer.cornerRadius = 24
        chatPanelView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }

    private func setupUI() {
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

        aiIconView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(chatPanelView.snp.top)
            make.size.equalTo(184)
        }

        chatPanelView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(backButton.snp.bottom).offset(175)
            make.bottom.equalTo(inputBarView.snp.top)
        }

        tableView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(110)
        }

        inputBarView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(64)
        }
    }

    private func setupEvents() {
        backButton.addTarget(self, action: #selector(clickBackButton), for: .touchUpInside)
        inputBarView.onSendTapped = { [weak self] text in
            self?.appendOutgoingMessage(text)
        }
    }


    private func appendOutgoingMessage(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        EP_NetworkTool.shared.fetchHuaPl(showsHUD: false) { result in
            switch result {
            case .success(_):
                self.sendMessage(trimmed)
            case .failure(_):
                self.sendMessage(trimmed)
            }
        }
    }
    
    private func sendMessage(_ trimmed: String){
        
        let avatar = EP_CurrentUser.shared.user?.avatar ?? "home_top"
        messages.append(
            EP_RoomMessageItem(kind: .outgoing, text: trimmed, avatarImageName: avatar)
        )
        tableView.reloadData()
        scrollToBottom(animated: true)
        scheduleAIReply()
    }

    private func scheduleAIReply() {
        let delay = Double.random(in: 1...4)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.appendIncomingReply()
        }
    }

    private func appendIncomingReply() {
        guard isPageActive, let reply = Self.replyScripts.randomElement() else { return }
        messages.append(
            EP_RoomMessageItem(kind: .incoming, text: reply, avatarImageName: "ai_icon")
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

    private let chatPanelView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.clipsToBounds = true
        return view
    }()

    private let aiIconView: UIImageView = {
        let view = UIImageView()
        view.image = "ai_icon".toImage
        view.contentMode = .scaleAspectFill
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
