//
//  EP_PersonVC.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/20.
//

import UIKit

class EP_PersonVC: EP_BaseVC {

    private enum Layout {
        static let rowHeight: CGFloat = 250
    }

    private var headerModel: EP_PersonHeaderModel
    private var feedItems: [EP_PostFeedItem]

    init(
        headerModel: EP_PersonHeaderModel = .preview,
        feedItems: [EP_PostFeedItem]? = nil
    ) {
        self.headerModel = headerModel
        self.feedItems = feedItems ?? Self.defaultFeedItems
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    convenience init(user: EP_UserModel) {
        self.init(headerModel: user.personHeaderModel, feedItems: user.postFeedItems)
    }

    /// 根据 userId 打开对方个人主页
    static func show(from viewController: UIViewController, userId: String) {
        guard !userId.isEmpty,
              let user = UserData.shared.user(userId: userId) else { return }
        viewController.navigationController?.pushViewController(
            EP_PersonVC(user: user),
            animated: true
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
        setupTableHeader()
        setupEvents()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeaderLayoutIfNeeded()
    }

    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(backButton)
    }

    private func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.size.equalTo(44)
        }
    }

    private func setupTableHeader() {
        personHeaderView.configure(with: headerModel)
        tableView.tableHeaderView = personHeaderView
    }

    private func setupEvents() {
        backButton.addTarget(self, action: #selector(clickBackButton), for: .touchUpInside)

        personHeaderView.onMoreTapped = { [weak self] in
            // TODO: Show more actions
        }
        personHeaderView.onFriendsTapped = { [weak self] in
            self?.navigationController?.pushViewController(EP_UserListVC(mode: .follow), animated: true)
        }
        personHeaderView.onFanTapped = { [weak self] in
            self?.navigationController?.pushViewController(EP_UserListVC(mode: .fan), animated: true)
        }
    }

    private func updateTableHeaderLayoutIfNeeded() {
        guard let header = tableView.tableHeaderView as? EP_PersonHeaderView else { return }
        let width = tableView.bounds.width
        let height = EP_PersonHeaderView.preferredHeight
        guard width > 0, header.frame.size != CGSize(width: width, height: height) else { return }
        header.frame = CGRect(x: 0, y: 0, width: width, height: height)
        tableView.tableHeaderView = header
    }

    @objc private func clickBackButton() {
        navigationController?.popViewController(animated: true)
    }

    private func toggleLike(at index: Int) {
        guard feedItems.indices.contains(index) else { return }
        feedItems[index].isLiked.toggle()
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
    }

    private lazy var personHeaderView: EP_PersonHeaderView = {
        EP_PersonHeaderView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: UIScreen.main.bounds.width,
                height: EP_PersonHeaderView.preferredHeight
            )
        )
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.rowHeight = Layout.rowHeight
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(EP_PostFeedCell.self, forCellReuseIdentifier: EP_PostFeedCell.reuseID)
        return tableView
    }()

    private let backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("common_back".toImage, for: .normal)
        return button
    }()

    private static let defaultFeedItems: [EP_PostFeedItem] = [
        EP_PostFeedItem(
            coverImageName: "post_temp",
            avatarImageName: "home_top",
            userName: "The non",
            content: "How's my outfit?How's my outfit?How's my outfit?",
            isLiked: false
        ),
        EP_PostFeedItem(
            coverImageName: "post_temp",
            avatarImageName: "home_top",
            userName: "The non",
            content: "How's my outfit?How's my outfit?How's my outfit?",
            isLiked: true
        ),
        EP_PostFeedItem(
            coverImageName: "post_temp",
            avatarImageName: "home_top",
            userName: "Wren",
            content: "How's my outfit?How's my outfit?How's my outfit?",
            isLiked: false
        ),
    ]
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension EP_PersonVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        feedItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: EP_PostFeedCell.reuseID,
            for: indexPath
        ) as? EP_PostFeedCell else {
            return UITableViewCell()
        }
        let item = feedItems[indexPath.row]
        cell.configure(with: item)
        cell.onLikeTapped = { [weak self] in
            self?.toggleLike(at: indexPath.row)
        }
        cell.onAvatarTapped = { [weak self] in
            guard let self else { return }
            EP_PersonVC.show(from: self, userId: item.userId)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(
            EP_DetailVC(item: feedItems[indexPath.row]),
            animated: true
        )
    }
}
