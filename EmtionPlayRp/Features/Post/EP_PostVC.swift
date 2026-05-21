//
//  EP_PostVC.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/18.
//

import UIKit

class EP_PostVC: EP_BaseVC {

    private var imagePosts: [EP_PostModel] = []
    private var feedItems: [EP_PostFeedItem] = []

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bgView.isHidden = true

        setupUI()
        setupConstraints()
        setupEvents()
    }
    
    private func loadData() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            UserData.shared.reload()
            let posts = UserData.shared.allImagePosts
            let items = posts.map(\.feedItem)
            DispatchQueue.main.async {
                self?.imagePosts = posts
                self?.feedItems = items
                self?.tableView.reloadData()
            }
        }
    }

    private func setupUI() {
        view.addSubview(bgV)
        view.addSubview(titleView)
        view.addSubview(releaseButton)
        view.addSubview(aiButton)
        view.addSubview(cosplayButton)
        view.addSubview(tableView)
    }

    private func setupConstraints() {
        bgV.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(17)
        }

        releaseButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(titleView)
        }

        aiButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(titleView.snp.bottom).offset(30)
            make.height.equalTo(109)
            make.trailing.equalTo(cosplayButton.snp.leading).offset(-9)
        }

        cosplayButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.width.height.equalTo(aiButton)
        }

        tableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(aiButton.snp.bottom).offset(25)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func setupEvents() {
        releaseButton.addTarget(self, action: #selector(clickReleaseButton), for: .touchUpInside)
        let aiTap = UITapGestureRecognizer(target: self, action: #selector(onAIButtonTapped))
        aiButton.addGestureRecognizer(aiTap)
        let cosTap = UITapGestureRecognizer(target: self, action: #selector(onCosButtonTapped))
        cosplayButton.addGestureRecognizer(cosTap)
    }
    
    @objc private func onAIButtonTapped() {
        navigationController?.pushViewController(EP_AIRoomVC(), animated: true)
    }
    
    @objc private func onCosButtonTapped() {
        navigationController?.pushViewController(EP_RoomVC(), animated: true)
    }
    
    @objc private func clickReleaseButton() {
        navigationController?.pushViewController(EP_ReleaseVC(), animated: true)
    }

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 250
        tableView.register(EP_PostFeedCell.self, forCellReuseIdentifier: EP_PostFeedCell.reuseID)
        return tableView
    }()

    private let bgV: UIImageView = {
        let view = UIImageView()
        view.image = "bg_02".toImage
        view.contentMode = .scaleAspectFill
        return view
    }()

    private let titleView: UIImageView = {
        let view = UIImageView()
        view.image = "post_title".toImage
        view.contentMode = .scaleAspectFill
        return view
    }()

    private let releaseButton: UIButton = {
        let v = UIButton(type: .custom)
        v.setImage("post_release".toImage, for: .normal)
        return v
    }()

    private let aiButton: UIImageView = {
        let v = UIImageView()
        v.image = "post_ai".toImage
        v.contentMode = .scaleAspectFill
        v.isUserInteractionEnabled = true
        return v
    }()

    private let cosplayButton: UIImageView = {
        let v = UIImageView()
        v.image = "post_cosplay".toImage
        v.contentMode = .scaleAspectFill
        v.isUserInteractionEnabled = true
        return v
    }()
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension EP_PostVC: UITableViewDataSource, UITableViewDelegate {

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
        cell.onMoreTapped = { [weak self] in
            self?.ep_presentReportSheet { option in
                if option == .block, !item.userId.isEmpty {
                    UserData.shared.setUserBlock(userId: item.userId, isBlock: true)
                }
            }
        }
        cell.onPostDeleted = { [weak self] in
            self?.loadData()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard imagePosts.indices.contains(indexPath.row) else { return }
        let post = imagePosts[indexPath.row]
        navigationController?.pushViewController(
            EP_DetailVC(post: post),
            animated: true
        )
    }

    private func toggleLike(at index: Int) {
        guard imagePosts.indices.contains(index) else { return }
        imagePosts[index].isLiked.toggle()
        UserData.shared.updatePost(imagePosts[index])
        feedItems[index] = imagePosts[index].feedItem
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
    }
}
