//
//  EP_SettingVC.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/18.
//

import UIKit

enum SettingRowType: CaseIterable {
    case contact
    case policy
    case guide
    case blacklist
    case logout
    case deleteAccount

    var imageName: String {
        switch self {
        case .contact: return "setting_contact"
        case .policy: return "setting_policy"
        case .guide: return "setting_guide"
        case .blacklist: return "setting_black"
        case .logout: return "setting_out"
        case .deleteAccount: return "setting_del"
        }
    }
}

class EP_SettingVC: EP_BaseVC {

    private enum Layout {
        static let horizontalInset: CGFloat = 16
        static let tableTopSpacing: CGFloat = 24
        static let rowSpacing: CGFloat = 14
        /// 设计稿单行卡片图高度（@3x 1029×201 → 343×67pt）
        static let rowImageHeight: CGFloat = 67
        static var rowHeight: CGFloat { rowImageHeight + rowSpacing }
    }

    private var tableHeightConstraint: Constraint?

    init() {
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let rows = SettingRowType.allCases

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupConstraints()
        setupEvents()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableMetricsIfNeeded()
    }

    private func updateTableMetricsIfNeeded() {
        let width = view.bounds.width - Layout.horizontalInset * 2
        guard width > 0 else { return }

        let rowHeight = Self.rowHeight(forTableWidth: width)
        guard tableView.rowHeight != rowHeight else { return }

        tableView.rowHeight = rowHeight
        tableView.estimatedRowHeight = rowHeight
        tableHeightConstraint?.update(offset: rowHeight * CGFloat(rows.count))
        tableView.reloadData()
    }

    private static func rowHeight(forTableWidth tableWidth: CGFloat) -> CGFloat {
        guard let image = SettingRowType.contact.imageName.toImage, image.size.width > 0 else {
            return Layout.rowHeight
        }
        let imageHeight = tableWidth * image.size.height / image.size.width
        return imageHeight + Layout.rowSpacing
    }

    private func setupUI() {
        view.addSubview(backButton)
        view.addSubview(titleView)
        view.addSubview(tableView)
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

        tableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.top.equalTo(titleView.snp.bottom).offset(Layout.tableTopSpacing)
            tableHeightConstraint = make.height.equalTo(Layout.rowHeight * CGFloat(rows.count)).constraint
        }
    }

    private func setupEvents() {
        backButton.addTarget(self, action: #selector(clickBackButton), for: .touchUpInside)
    }

    @objc private func clickBackButton() {
        navigationController?.popViewController(animated: true)
    }

    private func presentDeleteAccountConfirmation() {
        let alert = UIAlertController(
            title: "Delete Account",
            message: "This will permanently delete your account and all related data, including posts, chats, follows, blocks, and likes. This action cannot be undone.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.performDeleteAccount()
        })
        present(alert, animated: true)
    }

    private func performLogout() {
        EP_CurrentUser.shared.logout()
        EP_CurrentUser.shared.switchToWelcomeInterface()
    }

    private func performDeleteAccount() {
        guard EP_CurrentUser.shared.deleteAccountAndSignOut() else {
            let alert = UIAlertController(
                title: nil,
                message: "Failed to delete account. Please try again.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        EP_CurrentUser.shared.switchToWelcomeInterface()
    }

    private let backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("common_back".toImage, for: .normal)
        return button
    }()

    private let titleView: UIImageView = {
        let view = UIImageView()
        view.image = "setting_title".toImage
        view.contentMode = .scaleAspectFit
        return view
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.isScrollEnabled = false
        tableView.bounces = false
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.directionalLayoutMargins = .zero
        tableView.cellLayoutMarginsFollowReadableWidth = false
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.rowHeight = Layout.rowHeight
        tableView.estimatedRowHeight = Layout.rowHeight
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(EP_SettingImageCell.self, forCellReuseIdentifier: EP_SettingImageCell.reuseID)
        return tableView
    }()
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension EP_SettingVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: EP_SettingImageCell.reuseID,
            for: indexPath
        ) as? EP_SettingImageCell else {
            return UITableViewCell()
        }
        let tableWidth = tableView.bounds.width > 0
            ? tableView.bounds.width
            : view.bounds.width - Layout.horizontalInset * 2
        cell.configure(imageName: rows[indexPath.row].imageName, tableWidth: tableWidth)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let width = tableView.bounds.width
        return Self.rowHeight(forTableWidth: width > 0 ? width : view.bounds.width - Layout.horizontalInset * 2)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch rows[indexPath.row] {
        case .blacklist:
            navigationController?.pushViewController(EP_UserListVC(mode: .black), animated: true)
        case .logout:
            performLogout()
        case .deleteAccount:
            presentDeleteAccountConfirmation()
        case .guide:
            if let doc = URL(string: "https://docs.google.com/document/d/1rr4JRUudtCqCO8ey8Letm27G90eksmuaNYKaCS8UVUo/edit?usp=sharing") {
                UIApplication.shared.open(doc, options: [:], completionHandler: nil)
            }
        case .policy:
            if let doc = URL(string: "https://docs.google.com/document/d/1KjySwNvKO02TxihyZsO4LtVvomwdT4OX6NF00F8Pv0E/edit?usp=sharing") {
                UIApplication.shared.open(doc, options: [:], completionHandler: nil)
            }
        case .contact:
            navigationController?.pushViewController(EP_ContactVC(), animated: true)
        default:
            break
        }
    }
}

// MARK: - Cell

private final class EP_SettingImageCell: UITableViewCell {

    static let reuseID = "EP_SettingImageCell"

    private var imageHeightConstraint: Constraint?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        layoutMargins = .zero
        contentView.layoutMargins = .zero
        preservesSuperviewLayoutMargins = false
        contentView.preservesSuperviewLayoutMargins = false
        separatorInset = .zero

        contentView.addSubview(rowImageView)
        rowImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            imageHeightConstraint = make.height.equalTo(67).constraint
        }
        rowImageView.setContentHuggingPriority(.required, for: .vertical)
        rowImageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(imageName: String, tableWidth: CGFloat) {
        let image = imageName.toImage
        rowImageView.image = image
        let imageHeight: CGFloat
        if let image, image.size.width > 0 {
            imageHeight = tableWidth * image.size.height / image.size.width
        } else {
            imageHeight = 67
        }
        imageHeightConstraint?.update(offset: imageHeight)
    }

    private let rowImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
}
