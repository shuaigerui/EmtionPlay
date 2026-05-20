//
//  EP_UserModel.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/20.
//

import Foundation

struct EP_UserModel: Codable, Equatable {
    let userId: String
    var name: String
    var avatar: String
    var isBlock: Bool
    var followCount: Int
    var fanCount: Int
    var coins: Int
    var badge: Int

    static let preview = EP_UserModel(
        userId: "10001",
        name: "Marceline",
        avatar: "home_top",
        isBlock: false,
        followCount: 22,
        fanCount: 22,
        coins: 100,
        badge: 200
    )
}
