//
//  EP_LocalDatabase.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/20.
//

import Foundation

/// 本地 JSON 库：用户及其帖子（帖子挂在 user.posts 下）
struct EP_LocalDatabase: Codable, Equatable {
    var users: [EP_UserModel]
}

/// 旧版存储格式，用于迁移
private struct EP_LocalDatabaseLegacy: Codable {
    var users: [EP_UserModel]
    var posts: [EP_PostModel]?
}

extension EP_LocalDatabase {

    static func decode(from data: Data) throws -> EP_LocalDatabase {
        if let current = try? JSONDecoder().decode(EP_LocalDatabase.self, from: data) {
            return current
        }
        let legacy = try JSONDecoder().decode(EP_LocalDatabaseLegacy.self, from: data)
        return Self.migrated(from: legacy)
    }

    private static func migrated(from legacy: EP_LocalDatabaseLegacy) -> EP_LocalDatabase {
        var users = legacy.users
        guard let orphanPosts = legacy.posts, !orphanPosts.isEmpty else {
            return EP_LocalDatabase(users: users)
        }
        for post in orphanPosts {
            guard let index = users.firstIndex(where: { $0.userId == post.userId }) else { continue }
            if users[index].posts.contains(where: { $0.postId == post.postId }) { continue }
            users[index].posts.append(post)
        }
        return EP_LocalDatabase(users: users)
    }
}
