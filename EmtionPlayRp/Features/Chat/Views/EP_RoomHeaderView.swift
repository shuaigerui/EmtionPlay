//
//  EP_RoomHeaderView.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/19.
//

import UIKit

class EP_RoomHeaderView: UIView {

    var videoBlock: (() -> Void)?
    var moreBlock: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(cardView)
        addSubview(iconView)
        cardView.addSubview(nameLabel)
        cardView.addSubview(videoButton)
        cardView.addSubview(moreButton)
        
        cardView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
            make.height.equalTo(92)
        }
        iconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(22)
            make.top.equalToSuperview().offset(5)
            make.size.equalTo(110)
        }
        moreButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
            make.size.equalTo(52)
        }
        videoButton.snp.makeConstraints { make in
            make.trailing.equalTo(moreButton.snp.leading).offset(-6)
            make.size.centerY.equalTo(moreButton)
        }
        nameLabel.snp.makeConstraints { make in
            make.trailing.equalTo(videoButton.snp.leading).offset(-10)
            make.centerY.equalToSuperview()
            make.leading.equalTo(iconView.snp.trailing).offset(2)
        }
        
        videoButton.addTarget(self, action: #selector(clickVideoButton), for: .touchUpInside)
        moreButton.addTarget(self, action: #selector(clickMoreButton), for: .touchUpInside)
    }
    
    @objc private func clickVideoButton(){
        videoBlock?()
    }
    
    @objc private func clickMoreButton(){
        moreBlock?()
    }
    
    private let cardView: UIImageView = {
        let v = UIImageView()
        v.image = "room_card".toImage
        v.contentMode = .scaleAspectFill
        v.isUserInteractionEnabled = true
        return v
    }()
    
    private let iconView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.layer.cornerRadius = 55
        v.layer.masksToBounds = true
        return v
    }()
    
    private let nameLabel: UILabel = {
        let v = UILabel()
        v.textColor = .white
        v.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        return v
    }()
    
    private let videoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("room_video".toImage, for: .normal)
        return button
    }()
    
    private let moreButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("room_more".toImage, for: .normal)
        return button
    }()
    
    func configure(userName: String, avatarImageName: String) {
        nameLabel.text = userName
        iconView.image = avatarImageName.toImage
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
