//
//  EP_DetailInputView.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/19.
//

import UIKit

final class EP_DetailInputView: UIView {

    var onSendTapped: ((String) -> Void)?

    private enum Layout {
        static let horizontalInset: CGFloat = 16
        static let verticalInset: CGFloat = 10
        static let sendButtonSize: CGFloat = 52
        static let fieldHeight: CGFloat = 44
        static let fieldSendSpacing: CGFloat = 10
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white

        addSubview(inputField)
        addSubview(sendButton)

        sendButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.centerY.equalToSuperview()
            make.size.equalTo(Layout.sendButtonSize)
        }

        inputField.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(Layout.horizontalInset)
            make.trailing.equalTo(sendButton.snp.leading).offset(-Layout.fieldSendSpacing)
            make.top.bottom.equalToSuperview().inset(Layout.verticalInset)
            make.height.equalTo(Layout.fieldHeight)
        }

        sendButton.addTarget(self, action: #selector(onSendButtonTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func onSendButtonTapped() {
        let text = inputField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !text.isEmpty else { return }
        onSendTapped?(text)
        inputField.text = nil
    }

    private lazy var inputField: UITextField = {
        let field = UITextField()
        field.backgroundColor = .black
        field.textColor = .white
        field.font = .systemFont(ofSize: 15, weight: .regular)
        field.attributedPlaceholder = NSAttributedString(
            string: "Enter what you want to send",
            attributes: [
                .foregroundColor: UIColor.white.withAlphaComponent(0.6),
                .font: UIFont.systemFont(ofSize: 15, weight: .regular),
            ]
        )
        field.layer.cornerRadius = Layout.fieldHeight / 2
        field.clipsToBounds = true
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.leftViewMode = .always
        field.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        field.rightViewMode = .always
        field.returnKeyType = .send
        field.delegate = self
        return field
    }()

    private let sendButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("detail_send".toImage, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
}

extension EP_DetailInputView: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onSendButtonTapped()
        return true
    }
}
