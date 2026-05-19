//
//  EP_ChallengeCell.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/19.
//

import UIKit

struct EP_ChallengeItem {
    let coverImageName: String
    let likeCount: String
    let caption: String
}

final class EP_ChallengeCell: UICollectionViewCell {

    static let reuseID = "EP_ChallengeCell"

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true

        contentView.addSubview(coverImageView)
        contentView.addSubview(likeIconView)
        contentView.addSubview(likeCountLabel)
        contentView.addSubview(captionLabel)

        coverImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        likeIconView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-6)
            make.size.equalTo(42)
        }

        likeCountLabel.snp.makeConstraints { make in
            make.top.equalTo(likeIconView.snp.bottom)
            make.centerX.equalTo(likeIconView)
        }

        captionLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(8)
            make.trailing.leading.equalToSuperview().inset(6)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: EP_ChallengeItem) {
        coverImageView.image = item.coverImageName.toImage
        likeCountLabel.text = item.likeCount
        captionLabel.text = item.caption
    }

    private let coverImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        return view
    }()

    private let likeIconView: UIButton = {
        let view = UIButton(type: .custom)
        view.setImage("home_like".toImage, for: .normal)
        view.setImage("home_liked".toImage, for: .selected)
        return view
    }()

    private let likeCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let captionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
}
