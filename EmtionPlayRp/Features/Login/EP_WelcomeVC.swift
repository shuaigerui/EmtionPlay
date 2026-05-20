//
//  EP_WelcomeVC.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/18.
//

import UIKit

class EP_WelcomeVC: UIViewController {

    private enum Layout {
        static let buttonHeight: CGFloat = 68
        static let buttonSpacing: CGFloat = 16
        static let horizontalInset: CGFloat = 36
        static let bottomInset: CGFloat = 48
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        navigationController?.navigationBar.isHidden = true

        setupUI()
        setupConstraints()
        setupEvents()
    }

    func setupUI() {
        view.addSubview(bgView)
        view.addSubview(appleSignInButton)
        view.addSubview(createAccountButton)
        view.addSubview(signInButton)
    }

    func setupConstraints() {
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        signInButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.height.equalTo(Layout.buttonHeight)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(Layout.bottomInset)
        }

        createAccountButton.snp.makeConstraints { make in
            make.leading.trailing.height.equalTo(signInButton)
            make.bottom.equalTo(signInButton.snp.top).offset(-Layout.buttonSpacing)
        }

        appleSignInButton.snp.makeConstraints { make in
            make.leading.trailing.height.equalTo(signInButton)
            make.bottom.equalTo(createAccountButton.snp.top).offset(-Layout.buttonSpacing)
        }
    }

    func setupEvents() {
        appleSignInButton.addTarget(self, action: #selector(onAppleSignInTapped), for: .touchUpInside)
        createAccountButton.addTarget(self, action: #selector(onCreateAccountTapped), for: .touchUpInside)
        signInButton.addTarget(self, action: #selector(onSignInTapped), for: .touchUpInside)
    }

    @objc private func onAppleSignInTapped() {
        if EP_CurrentUser.shared.signInWithApple(displayName: nil, email: nil) {
            EP_CurrentUser.shared.switchToMainInterface()
        }
    }

    @objc private func onCreateAccountTapped() {
        navigationController?.pushViewController(EP_SetupVC(mode: .create), animated: true)
    }

    @objc private func onSignInTapped() {
        navigationController?.pushViewController(EP_SetupVC(mode: .signIn), animated: true)
    }

    private func makeLoginButton(title: String, systemImage: String? = nil) -> UIButton {
        let button = UIButton(type: .custom)
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .white
        config.baseForegroundColor = .black
        config.cornerStyle = .capsule
        config.title = title
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 20, weight: .semibold)
            return outgoing
        }
        if let systemImage {
            config.image = UIImage(systemName: systemImage)
            config.imagePadding = 8
            config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        }
        button.configuration = config
        return button
    }

    private lazy var appleSignInButton: UIButton = makeLoginButton(
        title: "Sign in with Apple",
        systemImage: "apple.logo"
    )

    private lazy var createAccountButton: UIButton = makeLoginButton(title: "Create Account")

    private lazy var signInButton: UIButton = makeLoginButton(title: "Sign in")

    private let bgView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.image = "wel_bg".toImage
        v.isUserInteractionEnabled = false
        return v
    }()
}
