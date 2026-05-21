//
//  EP_RoomVC.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/20.
//

import UIKit

class EP_RoomVC: EP_BaseVC {

    private enum Layout {
        static let horizontalTotalSpacing: CGFloat = 45
        static let cellHeight: CGFloat = 250
        static let lineSpacing: CGFloat = 12
        static let collectionTopSpacing: CGFloat = 16
    }

    private let rooms: [EP_RoomItem] = EP_RoomVC.defaultRooms

    /// 聊天室列表（封面 `Resource/Chat/chat_01` … `chat_06`）
    static let defaultRooms: [EP_RoomItem] = [
        EP_RoomItem(
            roomId: "r001",
            coverImageName: "chat_01",
            name: "Cosplay Fun",
            memberAvatarImageNames: ["avatar_01", "avatar_02", "avatar_03"]
        ),
        EP_RoomItem(
            roomId: "r002",
            coverImageName: "chat_02",
            name: "Cos Talk Zone",
            memberAvatarImageNames: ["avatar_02", "avatar_03", "avatar_04"]
        ),
        EP_RoomItem(
            roomId: "r003",
            coverImageName: "chat_03",
            name: "Cos Corner",
            memberAvatarImageNames: ["avatar_01", "avatar_04", "avatar_05"]
        ),
        EP_RoomItem(
            roomId: "r004",
            coverImageName: "chat_04",
            name: "Fandom Hangout",
            memberAvatarImageNames: ["avatar_03", "avatar_06"]
        ),
        EP_RoomItem(
            roomId: "r005",
            coverImageName: "chat_05",
            name: "Cos Corner",
            memberAvatarImageNames: ["avatar_02", "avatar_05", "avatar_07"]
        ),
        EP_RoomItem(
            roomId: "r006",
            coverImageName: "chat_06",
            name: "Item Chat",
            memberAvatarImageNames: ["avatar_04", "avatar_08", "avatar_09", "avatar_10"]
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
    }

    private func setupUI() {
        view.addSubview(backButton)
        view.addSubview(titleView)
        view.addSubview(collectionView)
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

        collectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(backButton.snp.bottom).offset(Layout.collectionTopSpacing)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private func setupEvents() {
        backButton.addTarget(self, action: #selector(clickBackButton), for: .touchUpInside)
    }

    private func cellSize(for collectionView: UICollectionView) -> CGSize {
        let width = collectionView.bounds.width > 0
            ? collectionView.bounds.width
            : view.bounds.width
        let cellWidth = (width - Layout.horizontalTotalSpacing) / 2
        return CGSize(width: cellWidth, height: Layout.cellHeight)
    }

    @objc private func clickBackButton() {
        navigationController?.popViewController(animated: true)
    }

    private let backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("common_back".toImage, for: .normal)
        return button
    }()

    private let titleView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = "room_title".toImage
        return view
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = Layout.lineSpacing
        layout.minimumInteritemSpacing = 13
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(EP_RoomCell.self, forCellWithReuseIdentifier: EP_RoomCell.reuseID)
        return collectionView
    }()
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegateFlowLayout

extension EP_RoomVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        rooms.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: EP_RoomCell.reuseID,
            for: indexPath
        ) as? EP_RoomCell else {
            return UICollectionViewCell()
        }
        let room = rooms[indexPath.item]
        cell.configure(with: room)
        cell.onJoinTapped = { [weak self] in
            self?.navigationController?.pushViewController(
                EP_ChatRoomVC(
                    peerName: room.name,
                    peerAvatarImageName: room.memberAvatarImageNames.first ?? "avatar_01",
                    peerUserId: nil
                ),
                animated: true
            )
        }
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        cellSize(for: collectionView)
    }
}
