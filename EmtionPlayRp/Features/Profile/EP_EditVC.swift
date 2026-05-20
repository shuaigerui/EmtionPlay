//
//  EP_EditVC.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/20.
//

import UIKit

class EP_EditVC: EP_BaseVC {

    private var avatarImageName: String
    private let initialNickname: String

    init(avatarImageName: String = "home_top", nickname: String = "Marceline") {
        self.avatarImageName = avatarImageName
        self.initialNickname = nickname
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
        avatarImageView.image = avatarImageName.toImage
        nameTextField.text = initialNickname
    }

    private func setupUI() {
        view.addSubview(backButton)
        view.addSubview(avatarContainerView)
        view.addSubview(avatarImageView)
        avatarContainerView.addSubview(changePhotoButton)
        view.addSubview(nickNameLabel)
        view.addSubview(nameTextField)
        view.addSubview(reviseButton)
    }

    private func setupConstraints() {
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.size.equalTo(44)
        }

        avatarContainerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(backButton.snp.bottom).offset(40)
            make.height.equalTo(146)
        }

        avatarImageView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.size.equalTo(158)
        }

        changePhotoButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-38)
            make.bottom.equalToSuperview().offset(-12)
            make.size.equalTo(40)
        }

        nickNameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(avatarContainerView.snp.bottom).offset(16)
            make.height.equalTo(34)
        }

        nameTextField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(nickNameLabel.snp.bottom).offset(18)
            make.height.equalTo(58)
            make.width.equalTo(240)
        }

        reviseButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(nameTextField.snp.bottom).offset(44)
            make.height.equalTo(75)
            make.width.equalTo(270)
        }
    }

    private func setupEvents() {
        backButton.addTarget(self, action: #selector(clickBackButton), for: .touchUpInside)
        changePhotoButton.addTarget(self, action: #selector(onChangePhotoTapped), for: .touchUpInside)
        reviseButton.addTarget(self, action: #selector(onReviseTapped), for: .touchUpInside)
    }

    @objc private func clickBackButton() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func onChangePhotoTapped() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }

    @objc private func onReviseTapped() {
        navigationController?.popViewController(animated: true)
    }

    private let backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("common_back".toImage, for: .normal)
        return button
    }()

    private let avatarContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = "#A591F2".toColor
        view.layer.cornerRadius = 64
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        return view
    }()

    private let avatarImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 79
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        return view
    }()

    private let changePhotoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("edit_pic".toImage, for: .normal)
        return button
    }()

    private let nickNameLabel: UILabel = {
        let label = UILabel()
        label.text = "NickName"
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textColor = .white
        return label
    }()

    private lazy var nameTextField: UITextField = {
        let field = UITextField()
        field.backgroundColor = .white
        field.textColor = .black
        field.font = .systemFont(ofSize: 16, weight: .regular)
        field.layer.cornerRadius = 24
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.black.cgColor
        field.clipsToBounds = true
        field.textAlignment = .center
        field.autocapitalizationType = .words
        field.autocorrectionType = .no
        field.attributedPlaceholder = NSAttributedString(
            string: "Enter a new name",
            attributes: [
                .foregroundColor: "#C4C4C4".toColor,
                .font: UIFont.systemFont(ofSize: 16, weight: .regular),
            ]
        )
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.leftViewMode = .always
        field.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.rightViewMode = .always
        return field
    }()

    private let reviseButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("edit_revise".toImage, for: .normal)
        return button
    }()
}

// MARK: - UIImagePickerControllerDelegate

extension EP_EditVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        if let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage {
            avatarImageView.image = image
        }
        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
