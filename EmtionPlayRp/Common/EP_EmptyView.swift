//
//  EP_EmptyView.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/21.
//

import UIKit

class EP_EmptyView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(emptyView)
        addSubview(emptyLabel)
        
        emptyView.snp.makeConstraints { make in
            make.centerX.top.equalToSuperview()
            make.width.height.equalTo(64)
        }
        emptyLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(emptyView.snp.bottom).offset(17)
            make.bottom.equalToSuperview()
        }
    }
    
    private let emptyView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.image = "common_empty".toImage
        return v
    }()
    private let emptyLabel: UILabel = {
        let v = UILabel()
        v.text = "No data available"
        v.textColor = "#666666".toColor
        v.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return v
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
