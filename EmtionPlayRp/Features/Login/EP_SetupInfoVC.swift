//
//  EP_SetupInfoVC.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/19.
//

import UIKit

class EP_SetupInfoVC: EP_BaseVC {

    private enum Layout {
        static let cardInset: CGFloat = 22
        static let fieldHeight: CGFloat = 54
        static let labelFieldSpacing: CGFloat = 19
        static let fieldGroupSpacing: CGFloat = 20
        static let formTopInset: CGFloat = 130
        static let formBottomInset: CGFloat = 28
        static let fieldHorizontalPadding: CGFloat = 16
        static let avatarSize: CGFloat = 160
        static let pickPhotoButtonSize: CGFloat = 40
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupConstraints()
        setupEvents()
    }

    private func setupUI() {

        view.addSubview(backButton)
        view.addSubview(cardView)
        view.addSubview(createButton)

        cardView.addSubview(avatarLabel)
        cardView.addSubview(avatarContainer)
        avatarContainer.addSubview(avatarImageView)
        avatarContainer.addSubview(pickPhotoButton)

        cardView.addSubview(nameLabel)
        cardView.addSubview(nameFieldContainer)
        nameFieldContainer.addSubview(nameTextField)
    }

    private func setupConstraints() {
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.size.equalTo(44)
        }

        cardView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(backButton.snp.bottom).offset(55)
        }

        avatarLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Layout.cardInset)
            make.top.equalToSuperview().offset(Layout.formTopInset)
        }

        avatarContainer.snp.makeConstraints { make in
            make.top.equalTo(avatarLabel.snp.bottom).offset(Layout.labelFieldSpacing)
            make.centerX.equalToSuperview()
            make.size.equalTo(Layout.avatarSize)
        }

        avatarImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        pickPhotoButton.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview()
            make.size.equalTo(Layout.pickPhotoButtonSize)
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(avatarLabel)
            make.top.equalTo(avatarContainer.snp.bottom).offset(Layout.fieldGroupSpacing)
        }

        nameFieldContainer.snp.makeConstraints { make in
            make.leading.trailing.equalTo(avatarLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(Layout.labelFieldSpacing)
            make.height.equalTo(Layout.fieldHeight)
        }

        nameTextField.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Layout.fieldHorizontalPadding)
            make.centerY.equalToSuperview()
        }

        cardView.snp.makeConstraints { make in
            make.bottom.equalTo(nameFieldContainer.snp.bottom).offset(Layout.formBottomInset)
        }

        createButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-75)
            make.height.equalTo(75)
            make.width.equalTo(295)
        }
    }

    private func setupEvents() {
        backButton.addTarget(self, action: #selector(clickBackButton), for: .touchUpInside)
        pickPhotoButton.addTarget(self, action: #selector(onPickPhotoTapped), for: .touchUpInside)
        let avatarTap = UITapGestureRecognizer(target: self, action: #selector(onPickPhotoTapped))
        avatarContainer.addGestureRecognizer(avatarTap)
    }

    @objc private func clickBackButton() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func onPickPhotoTapped() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }

    private func makeFieldLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .black
        return label
    }

    private func makeFieldContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = "#F1F1F1".toColor
        view.layer.cornerRadius = Layout.fieldHeight / 2
        view.clipsToBounds = true
        return view
    }

    private let backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("common_back".toImage, for: .normal)
        return button
    }()

    private let cardView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.isUserInteractionEnabled = true
        view.image = "setup_card".toImage
        return view
    }()

    private lazy var createButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("setup_button".toImage, for: .normal)
        return button
    }()

    private lazy var avatarLabel = makeFieldLabel(text: "Avatar")
    private lazy var nameLabel = makeFieldLabel(text: "Name")
    private lazy var nameFieldContainer = makeFieldContainer()

    private lazy var nameTextField: UITextField = {
        let field = UITextField()
        field.font = .systemFont(ofSize: 16, weight: .regular)
        field.textColor = .black
        field.autocapitalizationType = .words
        field.autocorrectionType = .no
        field.borderStyle = .none
        field.backgroundColor = .clear
        field.textContentType = .name
        return field
    }()

    private let avatarContainer: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        return view
    }()

    private let avatarImageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = "#F1F1F1".toColor
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()

    private lazy var pickPhotoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("login_pic".toImage, for: .normal)
        return button
    }()

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarImageView.layer.cornerRadius = Layout.avatarSize / 2
    }
}

extension EP_SetupInfoVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage
        avatarImageView.image = image
        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
