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
    /// 我关注的用户 id
    var followingIds: [String]
    /// 关注我的用户 id（粉丝）
    var fanIds: [String]
    /// 我拉黑的用户 id
    var blockedUserIds: [String]
    /// 我隐藏的帖子 id（举报后不再展示）
    var hiddenPostIds: [String]
    /// 我点赞的帖子 id（社区点赞，与帖子作者无关）
    var likedPostIds: [String]
    var coins: Int
    var badgeInfo: EP_BadgeModel
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
        followingIds: [String] = [],
        fanIds: [String] = [],
        blockedUserIds: [String] = [],
        hiddenPostIds: [String] = [],
        likedPostIds: [String] = [],
        coins: Int,
        badgeInfo: EP_BadgeModel = .empty,
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
        self.followingIds = followingIds
        self.fanIds = fanIds
        self.blockedUserIds = blockedUserIds
        self.hiddenPostIds = hiddenPostIds
        self.likedPostIds = likedPostIds
        self.coins = coins
        self.badgeInfo = badgeInfo
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
        followingIds = try container.decodeIfPresent([String].self, forKey: .followingIds) ?? []
        fanIds = try container.decodeIfPresent([String].self, forKey: .fanIds) ?? []
        blockedUserIds = try container.decodeIfPresent([String].self, forKey: .blockedUserIds) ?? []
        hiddenPostIds = try container.decodeIfPresent([String].self, forKey: .hiddenPostIds) ?? []
        likedPostIds = try container.decodeIfPresent([String].self, forKey: .likedPostIds) ?? []
        coins = try container.decode(Int.self, forKey: .coins)
        posts = try container.decodeIfPresent([EP_PostModel].self, forKey: .posts) ?? []
        if let info = try container.decodeIfPresent(EP_BadgeModel.self, forKey: .badgeInfo) {
            badgeInfo = info
        } else if let legacyBadge = try LegacyCodingKeys.decodeLegacyBadge(from: decoder) {
            badgeInfo = EP_BadgeModel(
                remain: legacyBadge,
                push: max(posts.count, 0),
                receive: 0,
                gain: 0
            )
        } else {
            badgeInfo = .empty
        }
    }

    private enum CodingKeys: String, CodingKey {
        case userId, name, avatar, email, password, isBlock, followCount, fanCount
        case followingIds, fanIds, blockedUserIds, hiddenPostIds, likedPostIds, coins, badgeInfo, posts
    }

    private enum LegacyCodingKeys: String, CodingKey {
        case badge

        static func decodeLegacyBadge(from decoder: Decoder) throws -> Int? {
            try decoder.container(keyedBy: Self.self).decodeIfPresent(Int.self, forKey: .badge)
        }
    }

    static let preview = EP_UserModel(
        userId: "10001",
        name: "Marceline",
        avatar: "home_top",
        isBlock: false,
        followCount: 22,
        fanCount: 22,
        coins: 100,
        badgeInfo: .preview
    )
}

extension EP_UserModel {

    var personHeaderModel: EP_PersonHeaderModel {
        let firstPost = posts.first
        let coverName: String = {
            guard let post = firstPost else { return "post_temp" }
            if !post.img.isEmpty { return post.img }
            return post.coverImage
        }()
        return EP_PersonHeaderModel(
            coverImageName: coverName,
            coverImage: firstPost.flatMap { EP_PostMedia.coverImage(for: $0) },
            avatarImageName: avatar,
            userName: name,
            badgeImageName: badgeInfo.profileBadgeImageName,
            friendsCount: followCount,
            fanCount: fanCount
        )
    }

    var postFeedItems: [EP_PostFeedItem] {
        posts.map { $0.feedItem() }
    }

    /// 更新昵称/头像后，同步该用户下所有帖子的作者展示字段
    mutating func syncPostsAuthorInfo() {
        for index in posts.indices {
            posts[index].authorName = name
            posts[index].authorAvatar = avatar
        }
    }
}
