//
//  UserData.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/20.
//

import Foundation

/// 本地用户与帖子数据（用户内嵌 posts，JSON 持久化）
final class UserData {

    static let shared = UserData()

    /// 当前本地登录用户（自己）的固定 id
    static let testUserId = "u_test"
    static let testAccountEmail = "test@gmail.com"
    static let testAccountPassword = "123456"

    private let fileName = "ep_local_database.json"

    private(set) var database: EP_LocalDatabase

    private init() {
        database = Self.loadFromDisk(fileName: fileName) ?? EP_LocalDatabase(users: [])
        if database.users.isEmpty {
            database = Self.seedDatabase
            save()
        } else {
            ensureTestUserExists()
        }
    }

    // MARK: - 查询

    /// 本地 test 用户（自己），可直接改属性后 `updateUser(testUser!)`
    var testUser: EP_UserModel? {
        user(userId: Self.testUserId)
    }

    var allUsers: [EP_UserModel] {
        database.users
    }

    /// 扁平化所有帖子（兼容列表页按帖展示）
    var allPosts: [EP_PostModel] {
        database.users.flatMap(\.posts)
    }

    func user(userId: String) -> EP_UserModel? {
        database.users.first { $0.userId == userId }
    }

    func user(email: String) -> EP_UserModel? {
        let normalized = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalized.isEmpty else { return nil }
        return database.users.first { $0.email.lowercased() == normalized }
    }

    func user(email: String, password: String) -> EP_UserModel? {
        let normalized = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalized.isEmpty else { return nil }
        return database.users.first {
            $0.email.lowercased() == normalized && $0.password == password
        }
    }

    @discardableResult
    func addUser(_ user: EP_UserModel) -> Bool {
        guard !database.users.contains(where: { $0.userId == user.userId }) else { return false }
        let email = user.email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !email.isEmpty, database.users.contains(where: { $0.email.lowercased() == email }) {
            return false
        }
        database.users.insert(user, at: 0)
        save()
        return true
    }

    func posts(userId: String) -> [EP_PostModel] {
        user(userId: userId)?.posts ?? []
    }

    func post(postId: String) -> EP_PostModel? {
        for user in database.users {
            if let post = user.posts.first(where: { $0.postId == postId }) {
                return post
            }
        }
        return nil
    }

    func userId(forPostId postId: String) -> String? {
        database.users.first { user in
            user.posts.contains { $0.postId == postId }
        }?.userId
    }

    func users(excludingBlocked: Bool = false) -> [EP_UserModel] {
        guard excludingBlocked else { return allUsers }
        return allUsers.filter { !$0.isBlock }
    }

    func posts(excludingBlockedUsers: Bool = false) -> [EP_PostModel] {
        guard excludingBlockedUsers else { return allPosts }
        return database.users
            .filter { !$0.isBlock }
            .flatMap(\.posts)
    }

    // MARK: - 用户编辑

    @discardableResult
    func updateUser(_ user: EP_UserModel) -> Bool {
        guard let index = database.users.firstIndex(where: { $0.userId == user.userId }) else {
            return false
        }
        var updated = user
        updated.syncPostsAuthorInfo()
        database.users[index] = updated
        save()
        return true
    }

    @discardableResult
    func setUserBlock(userId: String, isBlock: Bool) -> Bool {
        guard var user = user(userId: userId) else { return false }
        user.isBlock = isBlock
        return updateUser(user)
    }

    @discardableResult
    func updateUser(
        userId: String,
        name: String? = nil,
        avatar: String? = nil,
        isBlock: Bool? = nil,
        followCount: Int? = nil,
        fanCount: Int? = nil,
        coins: Int? = nil,
        badge: Int? = nil
    ) -> Bool {
        guard var user = user(userId: userId) else { return false }
        if let name { user.name = name }
        if let avatar { user.avatar = avatar }
        if let isBlock { user.isBlock = isBlock }
        if let followCount { user.followCount = followCount }
        if let fanCount { user.fanCount = fanCount }
        if let coins { user.coins = coins }
        if let badge { user.badge = badge }
        return updateUser(user)
    }

    @discardableResult
    func updateUser(
        userId: String,
        email: String? = nil,
        password: String? = nil
    ) -> Bool {
        guard var user = user(userId: userId) else { return false }
        if let email { user.email = email }
        if let password { user.password = password }
        return updateUser(user)
    }

    // MARK: - 帖子（写入对应用户的 posts）

    @discardableResult
    func addPost(_ post: EP_PostModel, toUserId userId: String? = nil) -> Bool {
        let ownerId = userId ?? post.userId
        guard let index = database.users.firstIndex(where: { $0.userId == ownerId }) else {
            return false
        }
        guard !database.users[index].posts.contains(where: { $0.postId == post.postId }) else {
            return false
        }
        let owner = database.users[index]
        let newPost = EP_PostModel(
            postId: post.postId,
            userId: ownerId,
            authorName: owner.name,
            authorAvatar: owner.avatar,
            coverImage: post.coverImage,
            content: post.content,
            isLiked: post.isLiked,
            likeCount: post.likeCount,
            commentCount: post.commentCount,
            comments: post.comments
        )
        database.users[index].posts.append(newPost)
        save()
        return true
    }

    @discardableResult
    func updatePost(_ post: EP_PostModel) -> Bool {
        guard let userIndex = database.users.firstIndex(where: { user in
            user.posts.contains { $0.postId == post.postId }
        }) else {
            return false
        }
        guard let postIndex = database.users[userIndex].posts.firstIndex(where: { $0.postId == post.postId }) else {
            return false
        }
        let owner = database.users[userIndex]
        let newPost = EP_PostModel(
            postId: post.postId,
            userId: owner.userId,
            authorName: owner.name,
            authorAvatar: owner.avatar,
            coverImage: post.coverImage,
            content: post.content,
            isLiked: post.isLiked,
            likeCount: post.likeCount,
            commentCount: post.commentCount,
            comments: post.comments
        )
        database.users[userIndex].posts[postIndex] = newPost
        save()
        return true
    }

    @discardableResult
    func deletePost(postId: String) -> Bool {
        guard let userIndex = database.users.firstIndex(where: { user in
            user.posts.contains { $0.postId == postId }
        }) else {
            return false
        }
        database.users[userIndex].posts.removeAll { $0.postId == postId }
        save()
        return true
    }

    /// 重置为内置种子数据（调试用）
    func resetToSeed() {
        database = Self.seedDatabase
        save()
    }

    // MARK: - 持久化

    func save() {
        Self.saveToDisk(database, fileName: fileName)
    }

    func reload() {
        database = Self.loadFromDisk(fileName: fileName) ?? database
    }

    private static func loadFromDisk(fileName: String) -> EP_LocalDatabase? {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent(fileName)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? EP_LocalDatabase.decode(from: data)
    }

    private static func saveToDisk(_ database: EP_LocalDatabase, fileName: String) {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent(fileName)
        guard let data = try? JSONEncoder().encode(database) else { return }
        try? data.write(to: url, options: .atomic)
    }

    /// 若已有旧数据但缺少 test 用户，启动时自动补上
    private func ensureTestUserExists() {
        if user(userId: Self.testUserId) == nil {
            database.users.insert(Self.buildTestUser(), at: 0)
            save()
            return
        }
        if var test = user(userId: Self.testUserId),
           test.email.isEmpty || test.password.isEmpty {
            test.email = Self.testAccountEmail
            test.password = Self.testAccountPassword
            updateUser(test)
        }
    }

    // MARK: - 种子数据（可按需修改）

    /// 内置 test 用户，可在种子或 `ensureTestUserExists` 中使用
    static func buildTestUser() -> EP_UserModel {
        let comment = EP_PostCommentModel(
            commentId: "c_test",
            userId: testUserId,
            userName: "Test",
            avatar: "avatar_05",
            content: "Just now",
            createdAtText: "Just now"
        )
        return EP_UserModel(
            userId: testUserId,
            name: "Test",
            avatar: "avatar_05",
            email: UserData.testAccountEmail,
            password: UserData.testAccountPassword,
            isBlock: false,
            followCount: 22,
            fanCount: 22,
            coins: 123_123,
            badge: 200,
            posts: [
                EP_PostModel(
                    postId: "p_test_01",
                    userId: testUserId,
                    authorName: "Test",
                    authorAvatar: "avatar_05",
                    coverImage: "post_temp",
                    content: "How's my outfit?How's my outfit?How's my outfit?",
                    isLiked: false,
                    likeCount: 8,
                    commentCount: 1,
                    comments: [comment]
                ),
                EP_PostModel(
                    postId: "p_test_02",
                    userId: testUserId,
                    authorName: "Test",
                    authorAvatar: "avatar_05",
                    coverImage: "post_temp",
                    content: "My first post here.",
                    isLiked: true,
                    likeCount: 15,
                    commentCount: 2,
                    comments: [comment, comment]
                ),
            ]
        )
    }

    static let seedDatabase: EP_LocalDatabase = {
        let commentSample = EP_PostCommentModel(
            commentId: "c_seed",
            userId: "u004",
            userName: "Nana",
            avatar: "avatar_04",
            content: "An hour ago",
            createdAtText: "An hour ago"
        )

        func makePost(
            postId: String,
            userId: String,
            authorName: String,
            authorAvatar: String,
            content: String,
            isLiked: Bool = false,
            likeCount: Int = 12,
            commentCount: Int = 1
        ) -> EP_PostModel {
            EP_PostModel(
                postId: postId,
                userId: userId,
                authorName: authorName,
                authorAvatar: authorAvatar,
                coverImage: "post_temp",
                content: content,
                isLiked: isLiked,
                likeCount: likeCount,
                commentCount: commentCount,
                comments: Array(repeating: commentSample, count: commentCount)
            )
        }

        let users: [EP_UserModel] = [
            UserData.buildTestUser(),
            EP_UserModel(
                userId: "u001",
                name: "Marceline",
                avatar: "avatar_01",
                isBlock: false,
                followCount: 22,
                fanCount: 22,
                coins: 120,
                badge: 200,
                posts: [
                    makePost(
                        postId: "p001",
                        userId: "u001",
                        authorName: "Marceline",
                        authorAvatar: "avatar_01",
                        content: "How's my outfit?How's my outfit?",
                        isLiked: true,
                        commentCount: 2
                    ),
                    makePost(
                        postId: "p002",
                        userId: "u001",
                        authorName: "Marceline",
                        authorAvatar: "avatar_01",
                        content: "Pink vibes today.",
                        commentCount: 1
                    ),
                ]
            ),
            EP_UserModel(
                userId: "u002",
                name: "Street",
                avatar: "avatar_02",
                isBlock: false,
                followCount: 18,
                fanCount: 35,
                coins: 88,
                badge: 150,
                posts: [
                    makePost(
                        postId: "p003",
                        userId: "u002",
                        authorName: "Street",
                        authorAvatar: "avatar_02",
                        content: "Street style check.",
                        isLiked: true,
                        commentCount: 3
                    ),
                    makePost(
                        postId: "p004",
                        userId: "u002",
                        authorName: "Street",
                        authorAvatar: "avatar_02",
                        content: "New cosplay wip.",
                        commentCount: 1
                    ),
                ]
            ),
            EP_UserModel(
                userId: "u003",
                name: "Thom",
                avatar: "avatar_03",
                isBlock: false,
                followCount: 10,
                fanCount: 12,
                coins: 50,
                badge: 80,
                posts: [
                    makePost(
                        postId: "p005",
                        userId: "u003",
                        authorName: "Thom",
                        authorAvatar: "avatar_03",
                        content: "How's my outfit?How's my outfit?How's my outfit?",
                        commentCount: 2
                    ),
                ]
            ),
            EP_UserModel(
                userId: "u004",
                name: "Nana",
                avatar: "avatar_04",
                isBlock: false,
                followCount: 30,
                fanCount: 40,
                coins: 200,
                badge: 300,
                posts: [
                    makePost(
                        postId: "p006",
                        userId: "u004",
                        authorName: "Nana",
                        authorAvatar: "avatar_04",
                        content: "Weekend mood.",
                        commentCount: 1
                    ),
                    makePost(
                        postId: "p007",
                        userId: "u004",
                        authorName: "Nana",
                        authorAvatar: "avatar_04",
                        content: "Thanks for all the likes!",
                        isLiked: true,
                        commentCount: 2
                    ),
                ]
            ),
        ]

        return EP_LocalDatabase(users: users)
    }()
}

// 兼容旧命名
typealias EP_LocalDataStore = UserData
