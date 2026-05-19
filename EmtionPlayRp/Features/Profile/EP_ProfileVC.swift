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

    private var releaseItems: [EP_PostFeedItem] = [
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
    ]

    private var likeItems: [EP_PostFeedItem] = [
        EP_PostFeedItem(
            coverImageName: "post_temp",
            avatarImageName: "home_top",
            userName: "Wren",
            content: "How's my outfit?How's my outfit?How's my outfit?",
            isLiked: true
        ),
    ]

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
                height: EP_ProfileHeaderView.preferredHeight
            )
        )
        header.configure(with: headerModel)
        header.onTabChanged = { [weak self] tab in
            self?.switchTab(tab)
        }
        header.onSettingTapped = { [weak self] in
            self?.navigationController?.pushViewController(EP_SettingVC(), animated: true)
        }
        return header
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupConstraints()
        setupTableHeader()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeaderLayoutIfNeeded()
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

    private func updateTableHeaderLayoutIfNeeded() {
        guard let header = tableView.tableHeaderView else { return }
        let width = tableView.bounds.width
        let height = EP_ProfileHeaderView.preferredHeight
        guard width > 0, header.frame.width != width || header.frame.height != height else { return }
        header.frame = CGRect(x: 0, y: 0, width: width, height: height)
        tableView.tableHeaderView = header
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
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(
            EP_DetailVC(item: activeItems[indexPath.row]),
            animated: true
        )
    }
}
