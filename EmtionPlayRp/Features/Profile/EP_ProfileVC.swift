//
//  EP_ProfileVC.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/18.
//

import UIKit

class EP_ProfileVC: EP_BaseVC {

    private enum Layout {
        static let rowHeight: CGFloat = 250
    }

    private var headerModel = EP_ProfileHeaderModel.preview
    private var selectedTab: EP_ProfileTab = .release

    private var releaseItems: [EP_PostFeedItem] = []
    private var likeItems: [EP_PostFeedItem] = []

    private var activeItems: [EP_PostFeedItem] {
        get { selectedTab == .release ? releaseItems : likeItems }
        set {
            if selectedTab == .release {
                releaseItems = newValue
            } else {
                likeItems = newValue
            }
        }
    }

    private lazy var profileHeaderView: EP_ProfileHeaderView = {
        let header = EP_ProfileHeaderView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: UIScreen.main.bounds.width,
                height: 610
            )
        )
        header.configure(with: headerModel)
        header.onTabChanged = { [weak self] tab in
            self?.switchTab(tab)
        }
        header.onSettingTapped = { [weak self] in
            self?.navigationController?.pushViewController(EP_SettingVC(), animated: true)
        }
        header.onShopTapped = { [weak self] in
            self?.navigationController?.pushViewController(EP_ShopVC(), animated: true)
        }
        header.onEditTapped = { [weak self] in
            guard let self else { return }
            let vc = EP_EditVC(
                avatarImageName: self.headerModel.avatarImageName,
                nickname: self.headerModel.userName
            )
            self.navigationController?.pushViewController(vc, animated: true)
        }
        header.onFriendsTapped = { [weak self] in
            self?.navigationController?.pushViewController(EP_UserListVC(mode: .follow), animated: true)
        }
        header.onFanTapped = { [weak self] in
            self?.navigationController?.pushViewController(EP_UserListVC(mode: .fan), animated: true)
        }
        header.onAchievementTapped = { [weak self] in
            guard let self else { return }
            self.navigationController?.pushViewController(
                EP_BadgeVC(avatarImageName: self.headerModel.avatarImageName),
                animated: true
            )
        }
        return header
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupConstraints()
        setupTableHeader()
    }
    
    private func loadData() {
        EP_CurrentUser.shared.refreshFromDatabase()
        guard let user = EP_CurrentUser.shared.user else { return }

        let firstPost = user.posts.first
        headerModel = EP_ProfileHeaderModel(
            coverImageName: firstPost?.coverImage ?? "post_temp",
            coverImage: firstPost.flatMap { EP_PostMedia.coverImage(for: $0) },
            avatarImageName: user.avatar,
            userName: user.name,
            friendsCount: user.followCount,
            fanCount: user.fanCount,
            selectedTab: selectedTab
        )
        profileHeaderView.configure(with: headerModel)

        releaseItems = user.posts.map(\.feedItem)
        likeItems = user.posts.filter(\.isLiked).map(\.feedItem)
        tableView.reloadData()
    }

    private func setupUI() {
        view.addSubview(tableView)
    }

    private func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupTableHeader() {
        tableView.tableHeaderView = profileHeaderView
    }

    private func switchTab(_ tab: EP_ProfileTab) {
        guard selectedTab != tab else { return }
        selectedTab = tab
        headerModel.selectedTab = tab
        tableView.reloadData()
    }

    private func toggleLike(at index: Int) {
        var items = activeItems
        guard items.indices.contains(index) else { return }
        items[index].isLiked.toggle()
        activeItems = items
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
    }

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = UIColor.color(hexString: "#F8D4E8")
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.rowHeight = Layout.rowHeight
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(EP_PostFeedCell.self, forCellReuseIdentifier: EP_PostFeedCell.reuseID)
        return tableView
    }()
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension EP_ProfileVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        activeItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: EP_PostFeedCell.reuseID,
            for: indexPath
        ) as? EP_PostFeedCell else {
            return UITableViewCell()
        }
        let item = activeItems[indexPath.row]
        cell.configure(with: item)
        cell.onLikeTapped = { [weak self] in
            self?.toggleLike(at: indexPath.row)
        }
        cell.onAvatarTapped = { [weak self] in
            guard let self else { return }
            EP_PersonVC.show(from: self, userId: item.userId)
        }
        cell.onMoreTapped = { [weak self] in
            self?.ep_presentReportSheet()
        }
        cell.onPostDeleted = { [weak self] in
            self?.loadData()
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = activeItems[indexPath.row]
        guard let post = UserData.shared.post(postId: item.postId) else { return }
        navigationController?.pushViewController(EP_DetailVC(post: post), animated: true)
    }
}
