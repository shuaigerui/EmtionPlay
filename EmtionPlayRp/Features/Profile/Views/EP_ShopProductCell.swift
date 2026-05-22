//
//  EP_ShopProductCell.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/19.
//

import UIKit

struct EP_ShopProductItem {
    let productId: String
    let coinAmount: Int
    let priceText: String
}

final class EP_ShopProductCell: UICollectionViewCell {

    static let reuseID = "EP_ShopProductCell"

    override var isSelected: Bool {
        didSet { updateSelectionAppearance() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 24
        contentView.clipsToBounds = true

        contentView.addSubview(coinRowStack)
        contentView.addSubview(priceLabel)

        coinRowStack.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(12)
//            make.leading.trailing.equalToSuperview().inset(5)
            make.centerX.equalToSuperview()
        }

        coinIconView.snp.makeConstraints { make in
            make.size.equalTo(36)
        }

        priceLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(5)
            make.bottom.equalToSuperview().inset(3)
        }

        updateSelectionAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: EP_ShopProductItem) {
        amountLabel.text = "\(item.coinAmount)"
        priceLabel.text = item.priceText
    }

    private func updateSelectionAppearance() {
        contentView.backgroundColor = isSelected ? "#C890F7".toColor : .white
    }

    private let coinIconView: UIImageView = {
        let view = UIImageView()
        view.image = "shop_coin".toImage
        view.contentMode = .scaleAspectFill
        return view
    }()

    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textColor = .black
        return label
    }()

    private lazy var coinRowStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [coinIconView, amountLabel])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 3
        return stack
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
}
