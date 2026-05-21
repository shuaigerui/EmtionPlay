//
//  EP_ContactVC.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/21.
//

import Toast_Swift
import UIKit

class EP_ContactVC: EP_BaseVC {

    private enum Layout {
        static let horizontalInset: CGFloat = 16
        static let cardTopSpacing: CGFloat = 32
        static let cardCornerRadius: CGFloat = 24
        static let cardPadding: CGFloat = 20
    }

    private static let contactEmail = "wizfeedback@gmail.com"

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
        view.addSubview(titleLabel)
        view.addSubview(cardView)
        cardView.addSubview(descLabel)
        cardView.addSubview(emailButton)
        cardView.addSubview(copyButton)
    }

    private func setupConstraints() {
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.size.equalTo(44)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backButton)
        }

        cardView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.top.equalTo(backButton.snp.bottom).offset(Layout.cardTopSpacing)
        }

        descLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(Layout.cardPadding)
        }

        emailButton.snp.makeConstraints { make in
            make.top.equalTo(descLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(Layout.cardPadding)
            make.height.equalTo(52)
        }

        copyButton.snp.makeConstraints { make in
            make.top.equalTo(emailButton.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview().inset(Layout.cardPadding)
            make.height.equalTo(48)
        }
    }

    private func setupEvents() {
        backButton.addTarget(self, action: #selector(clickBackButton), for: .touchUpInside)
        emailButton.addTarget(self, action: #selector(onEmailTapped), for: .touchUpInside)
        copyButton.addTarget(self, action: #selector(onCopyTapped), for: .touchUpInside)
    }

    @objc private func clickBackButton() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func onEmailTapped() {
        guard let url = URL(string: "mailto:\(Self.contactEmail)") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    @objc private func onCopyTapped() {
        UIPasteboard.general.string = Self.contactEmail
        view.makeToast("Email copied")
    }

    private let backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("common_back".toImage, for: .normal)
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Contact Us"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        return label
    }()

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.92)
        view.layer.cornerRadius = Layout.cardCornerRadius
        view.clipsToBounds = true
        return view
    }()

    private let descLabel: UILabel = {
        let label = UILabel()
        label.text = "If you have any questions, suggestions, or feedback, please contact us at:"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = "#333333".toColor
        label.numberOfLines = 0
        return label
    }()

    private lazy var emailButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = "#A591F2".toColor
        button.layer.cornerRadius = 26
        button.clipsToBounds = true
        button.setTitle(Self.contactEmail, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        return button
    }()

    private lazy var copyButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .black
        button.layer.cornerRadius = 24
        button.clipsToBounds = true
        button.setTitle("Copy Email", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        return button
    }()
}
