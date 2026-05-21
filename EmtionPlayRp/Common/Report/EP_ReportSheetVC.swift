//
//  EP_ReportSheetVC.swift
//  EmtionPlayRp
//

import UIKit

/// 举报底部弹窗（纯图片资源）
final class EP_ReportSheetVC: UIViewController {
    
    var onConfirm: ((EP_ReportOption) -> Void)?

    private var selectedOption: EP_ReportOption?
    private var optionButtons: [UIButton] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupUI()
        setupConstraints()
        setupEvents()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateIn()
    }

    // MARK: - UI

    private func setupUI() {
        view.addSubview(dimView)
        view.addSubview(panelView)
        view.addSubview(closeButton)
        panelView.addSubview(optionsStackView)
        panelView.addSubview(confirmButton)

        for option in EP_ReportOption.allCases {
            let button = makeOptionButton(option: option)
            optionButtons.append(button)
            optionsStackView.addArrangedSubview(button)
        }
    }

    private func setupConstraints() {
        dimView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        panelView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }

        closeButton.snp.makeConstraints { make in
            make.top.equalTo(panelView.snp.top).offset(-16)
            make.trailing.equalToSuperview().offset(-16)
            make.size.equalTo(32)
        }

        optionsStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.trailing.equalToSuperview()
        }

        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(optionsStackView.snp.bottom).offset(25)
            make.centerX.equalToSuperview()
            make.height.equalTo(75)
            make.width.equalTo(270)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-15)
        }
    }

    private func setupEvents() {
        dimView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeSheet)))
        closeButton.addTarget(self, action: #selector(closeSheet), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(onConfirmTapped), for: .touchUpInside)

        for (index, button) in optionButtons.enumerated() {
            button.tag = index
            button.addTarget(self, action: #selector(onOptionTapped(_:)), for: .touchUpInside)
        }
    }

    private func makeOptionButton(option: EP_ReportOption) -> UIButton {
        let button = UIButton(type: .custom)
        button.setImage(option.imageName.toImage, for: .normal)
        button.snp.makeConstraints { make in
            make.height.equalTo(59)
        }
        return button
    }

    private func updateOptionSelection() {
        for (index, button) in optionButtons.enumerated() {
            guard let option = EP_ReportOption(rawValue: index) else { continue }
            let isSelected = option == selectedOption
            button.alpha = isSelected ? 1 : 0.55
            button.transform = isSelected ? CGAffineTransform(scaleX: 1.02, y: 1.02) : .identity
        }
    }

    // MARK: - Actions

    @objc private func onOptionTapped(_ sender: UIButton) {
        selectedOption = EP_ReportOption(rawValue: sender.tag)
        updateOptionSelection()
    }

    @objc private func onConfirmTapped() {
        guard let selectedOption else {
            shakePanel()
            return
        }
        closeReportSheet(animated: true) { [weak self] in
            guard let self else { return }
            self.onConfirm?(selectedOption)
        }
    }

    @objc private func closeSheet() {
        closeReportSheet(animated: true, completion: nil)
    }

    private func closeReportSheet(animated: Bool, completion: (() -> Void)?) {
        guard animated else {
            dismiss(animated: false, completion: completion)
            return
        }
        UIView.animate(withDuration: 0.25, animations: {
            self.dimView.alpha = 0
            self.panelView.transform = CGAffineTransform(translationX: 0, y: self.panelView.bounds.height)
        }, completion: { _ in
            self.dismiss(animated: false, completion: completion)
        })
    }

    private func animateIn() {
        dimView.alpha = 0
        panelView.transform = CGAffineTransform(translationX: 0, y: panelView.bounds.height)
        UIView.animate(withDuration: 0.32, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.6) {
            self.dimView.alpha = 1
            self.panelView.transform = .identity
        }
    }

    private func shakePanel() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.4
        animation.values = [-8, 8, -6, 6, -4, 4, 0]
        panelView.layer.add(animation, forKey: "shake")
    }

    // MARK: - Views

    private let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()

    private let panelView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = "#010101".toColor.alpha(0.4)
        view.layer.cornerRadius = 32
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()

    private let closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("report_close".toImage, for: .normal)
        return button
    }()

    private let optionsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()

    private let confirmButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("report_comfirm".toImage, for: .normal)
        return button
    }()
}
