//
//  EP_WelcomeVC.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/18.
//

import AuthenticationServices
import Toast_Swift
import UIKit

class EP_WelcomeVC: UIViewController {

    private enum Layout {
        static let buttonHeight: CGFloat = 68
        static let buttonSpacing: CGFloat = 16
        static let horizontalInset: CGFloat = 36
        static let bottomInset: CGFloat = 48
    }

    private var appleAuthController: ASAuthorizationController?

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
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        appleAuthController = controller
        controller.performRequests()
    }

    private func handleAppleAuthorization(_ credential: ASAuthorizationAppleIDCredential) {
        let appleUserId = credential.user
        let displayName = Self.displayName(from: credential.fullName)
        let email = credential.email
        let avatarImage = Self.makeAvatarImage(from: displayName ?? "")

        guard EP_CurrentUser.shared.signInWithApple(
            appleUserId: appleUserId,
            displayName: displayName,
            email: email,
            avatarImage: avatarImage
        ) else {
            view.makeToast("Sign in with Apple failed. Please try again.")
            return
        }
        EP_CurrentUser.shared.switchToMainInterface()
    }

    private static func displayName(from components: PersonNameComponents?) -> String? {
        guard let components else { return nil }
        let formatter = PersonNameComponentsFormatter()
        let formatted = formatter.string(from: components)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return formatted.isEmpty ? nil : formatted
    }

    /// Apple 不提供头像，用姓名首字母生成圆形头像并写入沙盒
    private static func makeAvatarImage(from displayName: String, size: CGFloat = 256) -> UIImage {
        let fallbackName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        let nameForInitials = fallbackName.isEmpty ? "Apple User" : fallbackName
        let parts = nameForInitials.split(separator: " ").filter { !$0.isEmpty }
        let initials: String
        if parts.isEmpty {
            initials = "A"
        } else if parts.count == 1 {
            initials = String(parts[0].prefix(1)).uppercased()
        } else {
            initials = String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
        }

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        return renderer.image { ctx in
            let rect = CGRect(origin: .zero, size: CGSize(width: size, height: size))
            let cg = ctx.cgContext
            cg.setFillColor(red: 165 / 255, green: 145 / 255, blue: 242 / 255, alpha: 1)
            cg.fillEllipse(in: rect)

            let font = UIFont.systemFont(ofSize: size * 0.36, weight: .semibold)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.white,
            ]
            let text = initials as NSString
            let textSize = text.size(withAttributes: attributes)
            let origin = CGPoint(
                x: (size - textSize.width) / 2,
                y: (size - textSize.height) / 2
            )
            text.draw(at: origin, withAttributes: attributes)
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

// MARK: - Sign in with Apple

extension EP_WelcomeVC: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        view.window ?? UIApplication.window ?? UIWindow()
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        appleAuthController = nil
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            view.makeToast("Unable to read Apple ID credentials.")
            return
        }
        handleAppleAuthorization(credential)
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        appleAuthController = nil
        let nsError = error as NSError
        if nsError.domain == ASAuthorizationError.errorDomain,
           nsError.code == ASAuthorizationError.canceled.rawValue {
            return
        }
        view.makeToast("Sign in with Apple was cancelled or failed.")
    }
}
