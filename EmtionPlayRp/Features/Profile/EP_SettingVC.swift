//
//  EP_SettingVC.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/18.
//

import UIKit

enum SettingRowType: CaseIterable {
    case posts
    case contact
    case policy
    case guide
    case blacklist
    case logout
    case deleteAccount

    var imageName: String {
        switch self {
        case .posts:
            return "setting_posts"
        case .contact:
            return "setting_contact"
        case .policy:
            return "setting_policy"
        case .guide:
            return "setting_guide"
        case .blacklist:
            return "setting_black"
        case .logout:
            return "setting_out"
        case .deleteAccount:
            return "setting_del"
        }
    }
}

class EP_SettingVC: EP_BaseVC {

    private enum Layout {
        static let horizontalInset: CGFloat = 16
        static let tableTopSpacing: CGFloat = 24
        static let rowSpacing: CGFloat = 10
    }

    fileprivate static let rowSpacing = Layout.rowSpacing

    private let rows = SettingRowType.allCases

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupConstraints()
        setupEvents()
    }

    func setupUI() {
        view.addSubview(backButton)
        view.addSubview(titleView)
        view.addSubview(tableView)
    }

    func setupConstraints() {
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
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    func setupEvents() {
        backButton.addTarget(self, action: #selector(clickBackButton), for: .touchUpInside)
    }

    @objc private func clickBackButton() {
        navigationController?.popViewController(animated: true)
    }

    private func rowHeight(for imageName: String, tableWidth: CGFloat) -> CGFloat {
        guard let image = imageName.toImage, image.size.width > 0 else { return 64 }
        let imageHeight = tableWidth * image.size.height / image.size.width
        return imageHeight + Layout.rowSpacing
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
        cell.configure(imageName: rows[indexPath.row].imageName)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let tableWidth = tableView.bounds.width > 0
            ? tableView.bounds.width
            : UIScreen.main.bounds.width - Layout.horizontalInset * 2
        return rowHeight(for: rows[indexPath.row].imageName, tableWidth: tableWidth)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // TODO: Handle row action for rows[indexPath.row]
    }
}

// MARK: - Cell

private final class EP_SettingImageCell: UITableViewCell {

    static let reuseID = "EP_SettingImageCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.addSubview(rowImageView)
        rowImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(EP_SettingVC.rowSpacing)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(imageName: String) {
        rowImageView.image = imageName.toImage
    }

    private let rowImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        return view
    }()
}
