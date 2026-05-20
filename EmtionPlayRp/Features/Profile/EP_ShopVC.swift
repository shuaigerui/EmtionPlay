//
//  EP_ShopVC.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/19.
//

import UIKit

class EP_ShopVC: EP_BaseVC {

    private var balance: Int = 123_123
    private var selectedProductIndex: Int = 1

    private let products: [EP_ShopProductItem] = Array(
        repeating: EP_ShopProductItem(coinAmount: 10, priceText: "$ 10"),
        count: 9
    )

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
        updateBalanceText()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let indexPath = IndexPath(item: selectedProductIndex, section: 0)
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
    }

    private func setupUI() {
        view.addSubview(backButton)
        view.addSubview(titleView)
        view.addSubview(balanceCardView)
        view.addSubview(largeCoinView)
        balanceCardView.addSubview(remainingTitleLabel)
        balanceCardView.addSubview(balanceLabel)
        balanceCardView.addSubview(balanceDescLabel)
        view.addSubview(collectionView)
        view.addSubview(confirmButton)
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

        balanceCardView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(backButton.snp.bottom).offset(70)
            make.height.equalTo(146)
        }

        largeCoinView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.size.equalTo(112)
        }

        let w = (view.frame.width - 32)/2
        remainingTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(50)
            make.trailing.equalToSuperview().offset(-w)
            make.height.equalTo(34)
        }
        balanceLabel.snp.makeConstraints { make in
            make.leading.equalTo(remainingTitleLabel.snp.trailing).offset(6)
            make.centerY.equalTo(remainingTitleLabel)
            make.trailing.lessThanOrEqualToSuperview().offset(-10)
        }

        balanceDescLabel.snp.makeConstraints { make in
            make.top.equalTo(remainingTitleLabel.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(5)
        }

        confirmButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(75)
            make.width.equalTo(270)
        }

        collectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(balanceCardView.snp.bottom).offset(16)
            make.bottom.equalTo(confirmButton.snp.top).offset(-48)
            make.height.equalTo(272)
        }
    }

    private func setupEvents() {
        backButton.addTarget(self, action: #selector(clickBackButton), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(onConfirmTapped), for: .touchUpInside)
    }

    private func updateBalanceText() {
        balanceLabel.text = "\(balance)"
    }

    private func cellSize(for collectionView: UICollectionView) -> CGSize {

        let cellWidth = (UIScreen.main.bounds.width - 42) / 3
        return CGSize(width: cellWidth, height: 80)
    }

    @objc private func clickBackButton() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func onConfirmTapped() {
        guard products.indices.contains(selectedProductIndex) else { return }
        let product = products[selectedProductIndex]
        balance += product.coinAmount
        updateBalanceText()
    }

    private let backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("common_back".toImage, for: .normal)
        return button
    }()

    private let titleView: UIImageView = {
        let view = UIImageView()
        view.image = "shop_title".toImage
        view.contentMode = .scaleAspectFit
        return view
    }()

    private let balanceCardView: UIView = {
        let view = UIView()
        view.backgroundColor = "#A591F2".toColor
        view.layer.cornerRadius = 64
        view.clipsToBounds = true
        return view
    }()

    private let largeCoinView: UIImageView = {
        let view = UIImageView()
        view.image = "shop_coin".toImage
        view.contentMode = .scaleAspectFill
        return view
    }()

    private let remainingTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Remaining"
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textColor = .white
        return label
    }()

    private let balanceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textColor = "#FF6A6A".toColor
        return label
    }()

    private let balanceDescLabel: UILabel = {
        let label = UILabel()
        label.text = "It can be used to post your moments and frustrations."
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(
            top: 0,
            left: 16,
            bottom: 0,
            right: 16
        )

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = false
        collectionView.register(EP_ShopProductCell.self, forCellWithReuseIdentifier: EP_ShopProductCell.reuseID)
        return collectionView
    }()

    private let confirmButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("shop_comfirm".toImage, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegateFlowLayout

extension EP_ShopVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        products.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: EP_ShopProductCell.reuseID,
            for: indexPath
        ) as? EP_ShopProductCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: products[indexPath.item])
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        cellSize(for: collectionView)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedProductIndex = indexPath.item
    }
}
