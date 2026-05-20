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
    var email: String
    var password: String
    var isBlock: Bool
    var followCount: Int
    var fanCount: Int
    var coins: Int
    var badge: Int
    var posts: [EP_PostModel]

    init(
        userId: String,
        name: String,
        avatar: String,
        email: String = "",
        password: String = "",
        isBlock: Bool,
        followCount: Int,
        fanCount: Int,
        coins: Int,
        badge: Int,
        posts: [EP_PostModel] = []
    ) {
        self.userId = userId
        self.name = name
        self.avatar = avatar
        self.email = email
        self.password = password
        self.isBlock = isBlock
        self.followCount = followCount
        self.fanCount = fanCount
        self.coins = coins
        self.badge = badge
        self.posts = posts
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userId = try container.decode(String.self, forKey: .userId)
        name = try container.decode(String.self, forKey: .name)
        avatar = try container.decode(String.self, forKey: .avatar)
        email = try container.decodeIfPresent(String.self, forKey: .email) ?? ""
        password = try container.decodeIfPresent(String.self, forKey: .password) ?? ""
        isBlock = try container.decode(Bool.self, forKey: .isBlock)
        followCount = try container.decode(Int.self, forKey: .followCount)
        fanCount = try container.decode(Int.self, forKey: .fanCount)
        coins = try container.decode(Int.self, forKey: .coins)
        badge = try container.decode(Int.self, forKey: .badge)
        posts = try container.decodeIfPresent([EP_PostModel].self, forKey: .posts) ?? []
    }

    private enum CodingKeys: String, CodingKey {
        case userId, name, avatar, email, password, isBlock, followCount, fanCount, coins, badge, posts
    }

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

extension EP_UserModel {

    /// 更新昵称/头像后，同步该用户下所有帖子的作者展示字段
    mutating func syncPostsAuthorInfo() {
        for index in posts.indices {
            posts[index].authorName = name
            posts[index].authorAvatar = avatar
        }
    }
}
