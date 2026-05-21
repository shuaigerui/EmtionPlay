//
//  EP_VideoRoomVC.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/21.
//

import UIKit

class EP_VideoRoomVC: EP_BaseVC {

    private enum Layout {
        static let peerCardSize = CGSize(width: 112, height: 148)
        static let peerCardCorner: CGFloat = 20
        static let peerTrailing: CGFloat = 16
        static let peerBottom: CGFloat = 120
        static let controlButtonSize: CGFloat = 52
        static let controlSpacing: CGFloat = 12
        static let controlLeading: CGFloat = 16
        static let controlBottom: CGFloat = 40
    }

    private let peerName: String
    private let peerAvatarImageName: String
    private var isMicEnabled = true
    private var isVideoEnabled = true

    init(peerName: String, peerAvatarImageName: String) {
        self.peerName = peerName
        self.peerAvatarImageName = peerAvatarImageName
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 先检查相机权限，通过后再进入视频通话页
    static func show(
        from viewController: UIViewController,
        peerName: String,
        peerAvatarImageName: String
    ) {
        EP_CameraPermission.checkCameraAccess(from: viewController) {
            let room = EP_VideoRoomVC(
                peerName: peerName,
                peerAvatarImageName: peerAvatarImageName
            )
            viewController.navigationController?.pushViewController(room, animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        bgView.isHidden = true
        view.backgroundColor = .black

        setupUI()
        setupConstraints()
        setupEvents()
        applyPeerInfo()
        updateControlButtons()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cameraPreviewView.start()
        waitingDotsView.startAnimating()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cameraPreviewView.stop()
        waitingDotsView.stopAnimating()
    }

    // MARK: - UI

    private func setupUI() {
        view.addSubview(cameraPreviewView)
        view.addSubview(videoOffOverlayView)
        view.addSubview(backButton)
        view.addSubview(controlPanel)
        view.addSubview(peerAvatarImageView)
        view.addSubview(waitingDotsView)

        controlPanel.addSubview(reverseButton)
        controlPanel.addSubview(micOnButton)
        controlPanel.addSubview(videoOnButton)
        controlPanel.addSubview(endCallButton)
        
        micOnButton.setImage("video_mic_off".toImage, for: .selected)
        videoOnButton.setImage("video_video_off".toImage, for: .selected)
    }

    private func setupConstraints() {
        cameraPreviewView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        videoOffOverlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.size.equalTo(44)
        }

        peerAvatarImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-25)
            make.size.equalTo(172)
        }

        waitingDotsView.snp.makeConstraints { make in
            make.top.equalTo(peerAvatarImageView.snp.bottom).offset(15)
            make.centerX.equalTo(peerAvatarImageView)
            make.width.equalTo(56)
            make.height.equalTo(16)
        }

        let panelWidth = 52 * 2 + 30
        let panelHeight = 52 * 2 + 16
        controlPanel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-25)
            make.width.equalTo(panelWidth)
            make.height.equalTo(panelHeight)
        }

        layoutControlButtons()
    }

    private func layoutControlButtons() {

        reverseButton.snp.remakeConstraints { make in
            make.leading.top.equalToSuperview()
            make.size.equalTo(52)
        }
        micOnButton.snp.remakeConstraints { make in
            make.trailing.top.equalToSuperview()
            make.size.equalTo(52)
        }
        videoOnButton.snp.remakeConstraints { make in
            make.leading.bottom.equalToSuperview()
            make.size.equalTo(52)
        }
        endCallButton.snp.remakeConstraints { make in
            make.trailing.bottom.equalToSuperview()
            make.size.equalTo(52)
        }
    }

    private func setupEvents() {
        backButton.addTarget(self, action: #selector(clickBackButton), for: .touchUpInside)
        micOnButton.addTarget(self, action: #selector(onMicOnTapped), for: .touchUpInside)
        videoOnButton.addTarget(self, action: #selector(onVideoOnTapped), for: .touchUpInside)
        reverseButton.addTarget(self, action: #selector(onReverseTapped), for: .touchUpInside)
        endCallButton.addTarget(self, action: #selector(onEndCallTapped), for: .touchUpInside)
    }

    private func applyPeerInfo() {
        peerAvatarImageView.image = peerAvatarImageName.toAvatarImage ?? peerAvatarImageName.toImage
    }

    private func updateControlButtons() {
        micOnButton.isSelected = !isMicEnabled
        videoOnButton.isSelected = !isVideoEnabled
        videoOffOverlayView.isHidden = isVideoEnabled
        cameraPreviewView.isHidden = !isVideoEnabled
    }

    // MARK: - Actions

    @objc private func clickBackButton() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func onMicOnTapped() {
        isMicEnabled = !isMicEnabled
        updateControlButtons()
    }

    @objc private func onVideoOnTapped() {
        isVideoEnabled = !isVideoEnabled
        updateControlButtons()
    }

    @objc private func onReverseTapped() {
        cameraPreviewView.switchCamera()
    }

    @objc private func onEndCallTapped() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Views

    private let cameraPreviewView = EP_CameraPreviewView()

    private let videoOffOverlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.isHidden = true
        return view
    }()

    private let backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("common_back".toImage, for: .normal)
        return button
    }()

    private let controlPanel = UIView()

    private lazy var reverseButton = makeControlButton(imageName: "video_reverse")
    private lazy var micOnButton = makeControlButton(imageName: "video_mic")
    private lazy var videoOnButton = makeControlButton(imageName: "video_video")

    private lazy var endCallButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("video_off".toImage, for: .normal)
        return button
    }()

    private let peerAvatarImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        return view
    }()

    private let waitingDotsView = EP_WaitingDotsView()

    private func makeControlButton(imageName: String) -> UIButton {
        let button = UIButton(type: .custom)
        button.setImage(imageName.toImage, for: .normal)
        return button
    }
}
