//
//  EP_HomeHeaderView.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/19.
//

import UIKit

protocol EP_HomeHeaderViewDelegate: AnyObject {
    func homeHeaderViewDidTapOutfit(_ headerView: EP_HomeHeaderView)
}

class EP_HomeHeaderView: UICollectionReusableView {

    static let reuseID = "EP_HomeHeaderView"

    weak var delegate: EP_HomeHeaderViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(topView)
        addSubview(titleView)
        addSubview(outButton)
        addSubview(pushButton)

        outButton.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(onOutButtonTapped))
        outButton.addGestureRecognizer(tap)

        
        topView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.trailing.equalToSuperview()
            make.width.equalTo(307)
            make.height.equalTo(229)
        }
        titleView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(7)
            make.width.equalTo(181)
            make.height.equalTo(128)
        }
        outButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-30)
            make.leading.equalToSuperview().offset(16)
            make.height.equalTo(133)
        }
        pushButton.snp.makeConstraints { make in
            make.leading.equalTo(outButton.snp.trailing).offset(7)
            make.trailing.equalToSuperview().offset(-16)
            make.height.width.centerY.equalTo(outButton)
        }
    }
    
    private let topView: UIImageView = {
        let view = UIImageView()
        view.image = "home_top".toImage
        view.contentMode = .scaleAspectFill
        return view
    }()
    private let titleView: UIImageView = {
        let view = UIImageView()
        view.image = "home_title".toImage
        view.contentMode = .scaleAspectFill
        return view
    }()
//    private let outButton: UIButton = {
//        let v = UIButton(type: .custom)
//        v.setImage("home_outfit".toImage, for: .normal)
//        v.imageView?.contentMode = .scaleAspectFill
//        return v
//    }()
    private let outButton: UIImageView = {
        let view = UIImageView()
        view.image = "home_outfit".toImage
        view.contentMode = .scaleAspectFill
        return view
    }()
//    private let pushButton: UIButton = {
//        let v = UIButton(type: .custom)
//        v.setImage("home_push".toImage, for: .normal)
//        v.imageView?.contentMode = .scaleAspectFill
//        return v
//    }()
    private let pushButton: UIImageView = {
        let view = UIImageView()
        view.image = "home_push".toImage
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    @objc private func onOutButtonTapped() {
        delegate?.homeHeaderViewDidTapOutfit(self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
