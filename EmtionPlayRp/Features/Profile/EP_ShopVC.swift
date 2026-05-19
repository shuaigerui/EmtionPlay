//
//  EP_ShopVC.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/19.
//

import UIKit

class EP_ShopVC: EP_BaseVC {

    private enum Layout {
        static let horizontalInset: CGFloat = 16
        static let columnCount: CGFloat = 3
        static let interitemSpacing: CGFloat = 12
        static let lineSpacing: CGFloat = 12
        static let confirmButtonHeight: CGFloat = 74
        static let confirmBottomInset: CGFloat = 40
    }

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

        bgView.isHidden = true

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
        view.addSubview(bgV)
        view.addSubview(backButton)
        view.addSubview(titleView)
        view.addSubview(balanceCardView)
        balanceCardView.addSubview(largeCoinView)
        balanceCardView.addSubview(remainingTitleLabel)
        balanceCardView.addSubview(balanceLabel)
        balanceCardView.addSubview(balanceDescLabel)
        view.addSubview(collectionView)
        view.addSubview(confirmButton)
    }

    private func setupConstraints() {
        bgV.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

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
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.top.equalTo(backButton.snp.bottom).offset(8)
        }

        largeCoinView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.size.equalTo(112)
        }

        remainingTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(largeCoinView.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(20)
        }

        balanceLabel.snp.makeConstraints { make in
            make.leading.equalTo(remainingTitleLabel.snp.trailing).offset(6)
            make.centerY.equalTo(remainingTitleLabel)
            make.trailing.lessThanOrEqualToSuperview().offset(-20)
        }

        balanceDescLabel.snp.makeConstraints { make in
            make.top.equalTo(remainingTitleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(18)
        }

        confirmButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(Layout.confirmBottomInset)
            make.height.equalTo(Layout.confirmButtonHeight)
        }

        collectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(balanceCardView.snp.bottom).offset(16)
            make.bottom.equalTo(confirmButton.snp.top).offset(-16)
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
        let width = collectionView.bounds.width > 0
            ? collectionView.bounds.width
            : UIScreen.main.bounds.width
        let totalSpacing = Layout.horizontalInset * 2
            + Layout.interitemSpacing * (Layout.columnCount - 1)
        let cellWidth = (width - totalSpacing) / Layout.columnCount
        return CGSize(width: cellWidth, height: cellWidth * 1.05)
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

    private let bgV: UIImageView = {
        let view = UIImageView()
        view.image = "bg_02".toImage
        view.contentMode = .scaleAspectFill
        return view
    }()

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
        view.backgroundColor = "#C8B6FF".toColor
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()

    private let largeCoinView: UIImageView = {
        let view = UIImageView()
        view.image = "shop_coin".toImage
        view.contentMode = .scaleAspectFit
        return view
    }()

    private let remainingTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Remaining"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .white
        return label
    }()

    private let balanceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = "#FF6B57".toColor
        return label
    }()

    private let balanceDescLabel: UILabel = {
        let label = UILabel()
        label.text = "It can be used to post your moments and frustrations."
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = Layout.interitemSpacing
        layout.minimumLineSpacing = Layout.lineSpacing
        layout.sectionInset = UIEdgeInsets(
            top: 0,
            left: Layout.horizontalInset,
            bottom: 0,
            right: Layout.horizontalInset
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
