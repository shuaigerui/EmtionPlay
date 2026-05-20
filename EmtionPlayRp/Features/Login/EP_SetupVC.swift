//
//  EP_SetupVC.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/18.
//

import UIKit

class EP_SetupVC: EP_BaseVC {

    enum Mode {
        case signIn
        case create
    }

    private let mode: Mode

    init(mode: Mode) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private enum Layout {
        static let cardInset: CGFloat = 22
        static let fieldHeight: CGFloat = 54
        static let labelFieldSpacing: CGFloat = 19
        static let fieldGroupSpacing: CGFloat = 20
        static let formTopInset: CGFloat = 130
        static let formBottomInset: CGFloat = 28
        static let fieldIconSize: CGFloat = 24
        static let fieldHorizontalPadding: CGFloat = 16
        static let fieldIconTrailing: CGFloat = 14
    }

    private var isPasswordVisible = false

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupConstraints()
        setupEvents()
    }

    func setupUI() {
        switch mode {
        case .signIn:
            cardView.image = "login_card".toImage
            sureButton.setImage("login_next".toImage, for: .normal)
        case .create:
            cardView.image = "setup_card".toImage
            sureButton.setImage("setup_button".toImage, for: .normal)
        }

        view.addSubview(backButton)
        view.addSubview(cardView)
        view.addSubview(sureButton)

        cardView.addSubview(mailLabel)
        cardView.addSubview(mailFieldContainer)
        mailFieldContainer.addSubview(mailTextField)
        mailFieldContainer.addSubview(mailClearButton)

        cardView.addSubview(passwordLabel)
        cardView.addSubview(passwordFieldContainer)
        passwordFieldContainer.addSubview(passwordTextField)
        passwordFieldContainer.addSubview(passwordVisibilityButton)
    }

    func setupConstraints() {
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.size.equalTo(44)
        }

        cardView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(backButton.snp.bottom).offset(55)
        }

        mailLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Layout.cardInset)
            make.top.equalToSuperview().offset(Layout.formTopInset)
        }

        mailFieldContainer.snp.makeConstraints { make in
            make.leading.trailing.equalTo(mailLabel)
            make.top.equalTo(mailLabel.snp.bottom).offset(Layout.labelFieldSpacing)
            make.height.equalTo(Layout.fieldHeight)
        }

        mailClearButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Layout.fieldIconTrailing)
            make.centerY.equalToSuperview()
            make.size.equalTo(Layout.fieldIconSize)
        }

        mailTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Layout.fieldHorizontalPadding)
            make.trailing.equalTo(mailClearButton.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
        }

        passwordLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(mailLabel)
            make.top.equalTo(mailFieldContainer.snp.bottom).offset(Layout.fieldGroupSpacing)
        }

        passwordFieldContainer.snp.makeConstraints { make in
            make.leading.trailing.equalTo(mailLabel)
            make.top.equalTo(passwordLabel.snp.bottom).offset(Layout.labelFieldSpacing)
            make.height.equalTo(Layout.fieldHeight)
        }

        passwordVisibilityButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Layout.fieldIconTrailing)
            make.centerY.equalToSuperview()
            make.size.equalTo(Layout.fieldIconSize)
        }

        passwordTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Layout.fieldHorizontalPadding)
            make.trailing.equalTo(passwordVisibilityButton.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
        }

        sureButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-75)
            make.height.equalTo(75)
            make.width.equalTo(295)
        }
    }

    func setupEvents() {
        backButton.addTarget(self, action: #selector(clickBackButton), for: .touchUpInside)
        mailClearButton.addTarget(self, action: #selector(onMailClearTapped), for: .touchUpInside)
        passwordVisibilityButton.addTarget(self, action: #selector(onPasswordVisibilityTapped), for: .touchUpInside)
        mailTextField.addTarget(self, action: #selector(onMailTextChanged), for: .editingChanged)
        sureButton.addTarget(self, action: #selector(onSureTapped), for: .touchUpInside)
    }

    @objc private func onSureTapped() {
        let email = mailTextField.text ?? ""
        let password = passwordTextField.text ?? ""

        switch mode {
        case .signIn:
            if EP_CurrentUser.shared.signIn(email: email, password: password) {
                EP_CurrentUser.shared.switchToMainInterface()
            } else {
                showAlert(message: "Invalid email or password.")
            }
        case .create:
            guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  !password.isEmpty else {
                showAlert(message: "Please enter email and password.")
                return
            }
            let infoVC = EP_SetupInfoVC(email: email, password: password)
            navigationController?.pushViewController(infoVC, animated: true)
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func clickBackButton() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func onMailClearTapped() {
        mailTextField.text = nil
        updateMailClearButtonVisibility()
    }

    @objc private func onPasswordVisibilityTapped() {
        isPasswordVisible.toggle()
        passwordTextField.isSecureTextEntry = !isPasswordVisible
        let imageName = isPasswordVisible ? "login_show" : "login_hidden"
        passwordVisibilityButton.setImage(imageName.toImage, for: .normal)
    }

    @objc private func onMailTextChanged() {
        updateMailClearButtonVisibility()
    }

    private func updateMailClearButtonVisibility() {
        let hasText = !(mailTextField.text?.isEmpty ?? true)
        mailClearButton.isHidden = !hasText
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
        view.layer.masksToBounds = true
        return view
    }

    private func makeTextField(placeholder: String, isSecure: Bool = false) -> UITextField {
        let field = UITextField()
        field.font = .systemFont(ofSize: 16, weight: .regular)
        field.textColor = .black
        field.placeholder = placeholder
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.isSecureTextEntry = isSecure
        field.borderStyle = .none
        field.backgroundColor = .clear
        return field
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
        return view
    }()

    private lazy var mailLabel = makeFieldLabel(text: "Mail")
    private lazy var passwordLabel = makeFieldLabel(text: "Password")

    private lazy var mailFieldContainer = makeFieldContainer()
    private lazy var passwordFieldContainer = makeFieldContainer()

    private lazy var mailTextField: UITextField = {
        let field = makeTextField(placeholder: "")
        field.keyboardType = .emailAddress
        field.textContentType = .emailAddress
        return field
    }()

    private lazy var passwordTextField: UITextField = {
        let field = makeTextField(placeholder: "", isSecure: true)
        field.textContentType = .newPassword
        return field
    }()

    private lazy var mailClearButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("login_close".toImage, for: .normal)
        button.isHidden = true
        return button
    }()

    private lazy var passwordVisibilityButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("login_hidden".toImage, for: .normal)
        return button
    }()
    
    private lazy var sureButton: UIButton = {
        UIButton(type: .custom)
    }()
}
