//
//  EP_BaseVC.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/18.
//

import UIKit

class EP_BaseVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        // 隐藏导航栏（整个导航栏会消失）
        navigationController?.navigationBar.isHidden = true
        
        view.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    let bgView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.image = "bg_01".toImage
        v.isUserInteractionEnabled = false
        return v
    }()
}
