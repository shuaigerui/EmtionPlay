//
//  EP_ReleaseVC.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/19.
//

import Toast_Swift
import UIKit
import UniformTypeIdentifiers

class EP_ReleaseVC: EP_BaseVC {

    private enum PickedMedia {
        case image(UIImage)
        case video(URL)
    }

    private enum ToastMessage {
        static let emptyContent = "Please enter your content first."
        static let noMedia = "Please add a photo or video."
        static let insufficientCoins = "You need at least 10 coins. Please recharge first."
        static let publishFailed = "Failed to publish. Please try again."
        static let publishSuccess = "Posted successfully!"
    }

    private static let postCost = 10

    private var pickedMedia: PickedMedia?

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
        view.addSubview(textContainerView)
        textContainerView.addSubview(textView)
        textContainerView.addSubview(placeholderLabel)
        view.addSubview(addMediaButton)
        view.addSubview(costLabel)
        view.addSubview(submitButton)
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

        textContainerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(backButton.snp.bottom).offset(20)
            make.height.equalTo(180)
        }

        textView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }

        placeholderLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(textView).offset(4)
            make.trailing.lessThanOrEqualTo(textView).offset(-4)
        }

        addMediaButton.snp.makeConstraints { make in
            make.leading.equalTo(textContainerView)
            make.top.equalTo(textContainerView.snp.bottom).offset(16)
            make.size.equalTo(132)
        }

        submitButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(75)
            make.width.equalTo(267)
            make.height.equalTo(74)
        }

        costLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(submitButton.snp.top).offset(-15)
        }
    }

    private func setupEvents() {
        backButton.addTarget(self, action: #selector(clickBackButton), for: .touchUpInside)
        addMediaButton.addTarget(self, action: #selector(onAddMediaTapped), for: .touchUpInside)
        submitButton.addTarget(self, action: #selector(onSubmitTapped), for: .touchUpInside)
        textView.delegate = self
    }

    @objc private func clickBackButton() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func onAddMediaTapped() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        picker.mediaTypes = [UTType.image.identifier, UTType.movie.identifier]
        present(picker, animated: true)
    }

    @objc private func onSubmitTapped() {
        let content = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else {
            view.makeToast(ToastMessage.emptyContent)
            return
        }
        guard pickedMedia != nil else {
            view.makeToast(ToastMessage.noMedia)
            return
        }
        guard let currentUser = EP_CurrentUser.shared.user, currentUser.coins >= Self.postCost else {
            view.makeToast(ToastMessage.insufficientCoins)
            return
        }

        guard let post = buildPost(content: content, user: currentUser) else {
            view.makeToast(ToastMessage.publishFailed)
            return
        }
        guard UserData.shared.addPost(post, toUserId: currentUser.userId) else {
            view.makeToast(ToastMessage.publishFailed)
            return
        }
        UserData.shared.incrementBadgePush(userId: currentUser.userId)
        let newCoins = currentUser.coins - Self.postCost
        guard UserData.shared.updateUser(userId: currentUser.userId, coins: newCoins) else {
            view.makeToast(ToastMessage.publishFailed)
            return
        }
        EP_CurrentUser.shared.refreshFromDatabase()
        
        EP_NetworkTool.shared.fetchHuaPl { result in
            switch result {
            case .success(_):
                self.view.makeToast(ToastMessage.publishSuccess)
                self.navigationController?.popViewController(animated: true)
            case .failure(_):
                self.view.makeToast(ToastMessage.publishSuccess)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    private func buildPost(content: String, user: EP_UserModel) -> EP_PostModel? {
        let postId = "post_\(Int(Date().timeIntervalSince1970))_\(UUID().uuidString.prefix(6).lowercased())"
        var img = ""
        var video = ""

        switch pickedMedia {
        case .image(let image):
            guard let base = SS_PublishedPostMedia.savePhoto(image) else { return nil }
            img = base
        case .video(let url):
            let didAccess = url.startAccessingSecurityScopedResource()
            defer {
                if didAccess { url.stopAccessingSecurityScopedResource() }
            }
            guard let base = SS_PublishedPostMedia.saveVideo(from: url) else { return nil }
            video = base
        case .none:
            return nil
        }

        return EP_PostModel(
            postId: postId,
            userId: user.userId,
            authorName: user.name,
            authorAvatar: user.avatar,
            coverImage: "post_temp",
            img: img,
            video: video,
            content: content,
            isLiked: false,
            likeCount: 0,
            commentCount: 0,
            comments: []
        )
    }

    private func applyMediaPreview(image: UIImage) {
        addMediaButton.setImage(image, for: .normal)
        addMediaButton.imageView?.contentMode = .scaleAspectFill
    }

    private func updatePlaceholderVisibility() {
        placeholderLabel.isHidden = !(textView.text?.isEmpty ?? true)
    }

    private let backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("common_back".toImage, for: .normal)
        return button
    }()

    private let titleView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = "release_title".toImage
        return view
    }()

    private let textContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()

    private lazy var textView: UITextView = {
        let view = UITextView()
        view.font = .systemFont(ofSize: 16, weight: .regular)
        view.textColor = .black
        view.backgroundColor = .clear
        view.textContainerInset = .zero
        view.textContainer.lineFragmentPadding = 0
        return view
    }()

    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Tell me about your troubles."
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = "#999999".toColor
        label.numberOfLines = 0
        return label
    }()

    private let addMediaButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .white
        button.setImage("release_add".toImage, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        return button
    }()

    private let costLabel: UILabel = {
        let label = UILabel()
        label.text = "Unlocking dynamic posting costs 10 gold coins."
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = "#999999".toColor
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let submitButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("release_button".toImage, for: .normal)
        return button
    }()
}

// MARK: - UITextViewDelegate

extension EP_ReleaseVC: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        updatePlaceholderVisibility()
    }
}

// MARK: - UIImagePickerControllerDelegate

extension EP_ReleaseVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        picker.dismiss(animated: true)

        if let mediaURL = info[.mediaURL] as? URL {
            pickedMedia = .video(mediaURL)
            if let thumb = SS_BundleResourceMedia.videoFirstFrame(url: mediaURL) {
                applyMediaPreview(image: thumb)
            } else {
                addMediaButton.setImage("release_add".toImage, for: .normal)
            }
            return
        }

        if let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage {
            pickedMedia = .image(image)
            applyMediaPreview(image: image)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
