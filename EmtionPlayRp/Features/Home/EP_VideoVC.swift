//
//  EP_VideoVC.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/20.
//

import AVFoundation
import UIKit

class EP_VideoVC: EP_BaseVC {

    private let postItem: EP_PostFeedItem
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var isLiked: Bool

    init(item: EP_PostFeedItem) {
        self.postItem = item
        self.isLiked = item.isLiked
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        bgView.isHidden = true
        view.backgroundColor = .black

        setupPlayer()
        setupUI()
        setupConstraints()
        setupEvents()
        applyContent()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player?.play()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
        if isMovingFromParent {
            NotificationCenter.default.removeObserver(self)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = view.bounds
    }

    // MARK: - Player

    private func setupPlayer() {
        guard let url = EP_PostMedia.resolveVideoURL(postItem.video) else { return }

        let player = AVPlayer(url: url)
        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspectFill
        layer.frame = view.bounds
        view.layer.insertSublayer(layer, at: 0)

        self.player = player
        self.playerLayer = layer

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinish),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        )
    }

    @objc private func playerDidFinish() {
        player?.seek(to: .zero)
        player?.play()
    }

    // MARK: - UI

    private func setupUI() {
        view.addSubview(backButton)
        view.addSubview(avatarImageView)
        view.addSubview(nameLabel)
        view.addSubview(captionLabel)
        view.addSubview(actionStack)
    }

    private func setupConstraints() {

        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.size.equalTo(44)
        }
        
        actionStack.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalTo(avatarImageView.snp.top).offset(-90)
            make.width.equalTo(42)
            make.height.equalTo(100)
        }
        
        likeButton.snp.makeConstraints { make in
            make.size.equalTo(42)
        }

        moreButton.snp.makeConstraints { make in
            make.size.equalTo(42)
        }

        avatarImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalTo(captionLabel.snp.top).offset(10)
            make.size.equalTo(48)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(67)
            make.bottom.equalTo(captionLabel.snp.top)
            make.height.equalTo(28)
        }

        captionLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(67)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
    }

    private func setupEvents() {
        backButton.addTarget(self, action: #selector(clickBackButton), for: .touchUpInside)
        likeButton.addTarget(self, action: #selector(onLikeTapped), for: .touchUpInside)
    }

    private func applyContent() {
        avatarImageView.image = postItem.avatarImageName.toImage
        nameLabel.text = postItem.userName
        captionLabel.text = postItem.content
        likeButton.isSelected = isLiked
    }

    @objc private func clickBackButton() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func onLikeTapped() {
        isLiked.toggle()
        likeButton.isSelected = isLiked
    }

    // MARK: - Views
    private let backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("common_back".toImage, for: .normal)
        return button
    }()

    private let avatarImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 24
        view.layer.masksToBounds = true
        return view
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .white
        return label
    }()

    private let captionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()

    private lazy var actionStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [likeButton, moreButton])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()

    private lazy var likeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("home_like".toImage, for: .normal)
        button.setImage("home_liked".toImage, for: .selected)
        return button
    }()

    private lazy var moreButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("post_more".toImage, for: .normal)
        return button
    }()
}
