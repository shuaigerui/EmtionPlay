//
//  EP_DetailVC.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/19.
//

import Toast_Swift
import UIKit

class EP_DetailVC: EP_BaseVC {

    private enum Layout {
        static let headerHeight: CGFloat = 300
        static let inputBarHeight: CGFloat = 64
    }

    private let postId: String
    private var postItem: EP_PostFeedItem
    private var comments: [EP_DetailCommentItem]

    init(post: EP_PostModel) {
        postId = post.postId
        postItem = post.feedItem
        comments = post.detailCommentItems
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
    }

    private func setupUI() {
        view.addSubview(backButton)
        view.addSubview(titleView)
        view.addSubview(tableView)
        view.addSubview(inputBarView)
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

        inputBarView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(Layout.inputBarHeight)
        }

        tableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(backButton.snp.bottom).offset(10)
            make.bottom.equalTo(inputBarView.snp.top)
        }
    }

    private func setupEvents() {
        backButton.addTarget(self, action: #selector(clickBackButton), for: .touchUpInside)
        inputBarView.onSendTapped = { [weak self] text in
            self?.appendComment(text)
        }
    }

    private func setupTableHeader() {
        let header = EP_DetailHeaderView(
            frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: Layout.headerHeight)
        )
        header.configure(with: postItem)
        header.onLikeTapped = { [weak self] in
            self?.togglePostLike()
        }
        header.onCoverTapped = { [weak self] in
            self?.openVideoPlayerIfNeeded()
        }
        header.onMoreTapped = { [weak self] in
            self?.ep_presentReportSheet()
        }
        tableView.tableHeaderView = header
    }

    private func openVideoPlayerIfNeeded() {
        guard !postItem.video.isEmpty else { return }
        navigationController?.pushViewController(EP_VideoVC(item: postItem), animated: true)
    }

    private func updateTableHeaderLayoutIfNeeded() {
        guard let header = tableView.tableHeaderView else { return }
        let width = tableView.bounds.width
        guard width > 0, header.frame.width != width || header.frame.height != Layout.headerHeight else { return }
        header.frame = CGRect(x: 0, y: 0, width: width, height: Layout.headerHeight)
        tableView.tableHeaderView = header
    }

    private func togglePostLike() {
        guard var post = UserData.shared.post(postId: postId) else { return }
        let wasLiked = post.isLiked
        post.isLiked.toggle()
        if post.isLiked, !wasLiked {
            post.likeCount += 1
        } else if !post.isLiked, wasLiked {
            post.likeCount = max(0, post.likeCount - 1)
        }
        guard UserData.shared.updatePost(post) else { return }
        applyPost(post)
        (tableView.tableHeaderView as? EP_DetailHeaderView)?.configure(with: postItem)
    }

    private func appendComment(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard var post = UserData.shared.post(postId: postId),
              let currentUser = EP_CurrentUser.shared.user else { return }

        let comment = EP_PostCommentModel(
            commentId: "c_\(Int(Date().timeIntervalSince1970))_\(UUID().uuidString.prefix(6).lowercased())",
            userId: currentUser.userId,
            userName: currentUser.name,
            avatar: currentUser.avatar,
            content: trimmed,
            createdAtText: "Just now"
        )
        post.comments.append(comment)
        post.commentCount = post.comments.count
        guard UserData.shared.updatePost(post) else { return }

        applyPost(post)
        tableView.reloadData()
        let indexPath = IndexPath(row: comments.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        view.makeToast("Comment posted successfully.")
    }

    private func applyPost(_ post: EP_PostModel) {
        postItem = post.feedItem
        comments = post.detailCommentItems
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
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag
        tableView.register(EP_DetailCommentCell.self, forCellReuseIdentifier: EP_DetailCommentCell.reuseID)
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
        view.contentMode = .scaleAspectFit
        view.image = "detail_title".toImage
        return view
    }()
}

// MARK: - UITableViewDataSource

extension EP_DetailVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: EP_DetailCommentCell.reuseID,
            for: indexPath
        ) as? EP_DetailCommentCell else {
            return UITableViewCell()
        }
        cell.configure(with: comments[indexPath.row])
        return cell
    }
}
