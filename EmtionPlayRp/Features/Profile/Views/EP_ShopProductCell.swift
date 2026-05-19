//
//  EP_ShopProductCell.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/19.
//

import UIKit

struct EP_ShopProductItem {
    let coinAmount: Int
    let priceText: String
}

final class EP_ShopProductCell: UICollectionViewCell {

    static let reuseID = "EP_ShopProductCell"

    private enum Layout {
        static let cornerRadius: CGFloat = 16
        static let coinSize: CGFloat = 28
        static let contentInset = UIEdgeInsets(top: 14, left: 12, bottom: 12, right: 12)
    }

    override var isSelected: Bool {
        didSet { updateSelectionAppearance() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = Layout.cornerRadius
        contentView.clipsToBounds = true

        contentView.addSubview(coinRowStack)
        contentView.addSubview(priceLabel)

        coinRowStack.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(Layout.contentInset.top)
            make.leading.greaterThanOrEqualToSuperview().inset(Layout.contentInset.left)
            make.trailing.lessThanOrEqualToSuperview().inset(Layout.contentInset.right)
            make.centerX.equalToSuperview()
        }

        coinIconView.snp.makeConstraints { make in
            make.size.equalTo(Layout.coinSize)
        }

        priceLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Layout.contentInset.left)
            make.bottom.equalToSuperview().inset(Layout.contentInset.bottom)
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
        contentView.backgroundColor = isSelected ? "#D9CCFF".toColor : .white
        priceLabel.textColor = isSelected ? "#FF6B57".toColor : .black
    }

    private let coinIconView: UIImageView = {
        let view = UIImageView()
        view.image = "shop_coin".toImage
        view.contentMode = .scaleAspectFit
        return view
    }()

    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        return label
    }()

    private lazy var coinRowStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [coinIconView, amountLabel])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 6
        return stack
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
}
