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
            syncSeedPostsMediaIfNeeded()
            syncTestUserProfileFromSeedIfNeeded()
            syncTestUserBadgeInfoFromSeedIfNeeded()
        }
    }

    // MARK: - 查询

    private enum SessionKeys {
        static let isLoggedIn = "ep_is_logged_in"
        static let currentUserId = "ep_current_user_id"
    }

    private var sessionUserId: String? {
        guard UserDefaults.standard.bool(forKey: SessionKeys.isLoggedIn) else { return nil }
        return UserDefaults.standard.string(forKey: SessionKeys.currentUserId)
    }

    /// 所有带视频的帖子（首页等使用，已过滤隐藏帖与拉黑用户）
    var allVideoPosts: [EP_PostModel] {
        visiblePosts(allPosts.filter { !$0.video.isEmpty })
    }

    /// 纯图片帖子（社区页：有 img、无 video，已过滤隐藏帖与拉黑用户）
    var allImagePosts: [EP_PostModel] {
        visiblePosts(allPosts.filter { !$0.img.isEmpty && $0.video.isEmpty })
    }

    /// 对当前登录用户可见的帖子
    func visiblePosts(_ posts: [EP_PostModel]) -> [EP_PostModel] {
        let hiddenIds = Set(sessionUserId.flatMap { user(userId: $0)?.hiddenPostIds } ?? [])
        let blockedUserIds = Set(database.users.filter(\.isBlock).map(\.userId))
        return posts.filter { post in
            !hiddenIds.contains(post.postId) && !blockedUserIds.contains(post.userId)
        }
    }

    @discardableResult
    func hidePost(postId: String, ownerUserId: String) -> Bool {
        guard !postId.isEmpty, var owner = user(userId: ownerUserId) else { return false }
        if !owner.hiddenPostIds.contains(postId) {
            owner.hiddenPostIds.append(postId)
        }
        return updateUser(owner)
    }

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
    func setUserBlock(
        userId: String,
        isBlock: Bool,
        ownerUserId: String? = nil
    ) -> Bool {
        guard var blocked = user(userId: userId) else { return false }
        blocked.isBlock = isBlock
        guard updateUser(blocked) else { return false }

        guard let ownerId = ownerUserId, var owner = user(userId: ownerId) else { return true }
        if isBlock {
            if !owner.blockedUserIds.contains(userId) {
                owner.blockedUserIds.append(userId)
            }
        } else {
            owner.blockedUserIds.removeAll { $0 == userId }
        }
        return updateUser(owner)
    }

    func users(userIds: [String]) -> [EP_UserModel] {
        userIds.compactMap { user(userId: $0) }
    }

    func followingUsers(for userId: String) -> [EP_UserModel] {
        guard let user = user(userId: userId) else { return [] }
        return users(userIds: user.followingIds)
    }

    func fanUsers(for userId: String) -> [EP_UserModel] {
        guard let user = user(userId: userId) else { return [] }
        return users(userIds: user.fanIds)
    }

    func blockedUsers(for userId: String) -> [EP_UserModel] {
        guard let user = user(userId: userId) else { return [] }
        return users(userIds: user.blockedUserIds)
    }

    func isFollowing(ownerUserId: String, targetUserId: String) -> Bool {
        user(userId: ownerUserId)?.followingIds.contains(targetUserId) ?? false
    }

    @discardableResult
    func followUser(ownerUserId: String, targetUserId: String) -> Bool {
        guard ownerUserId != targetUserId,
              var owner = user(userId: ownerUserId),
              user(userId: targetUserId) != nil else { return false }
        guard !owner.followingIds.contains(targetUserId) else { return true }

        owner.followingIds.append(targetUserId)
        owner.followCount = owner.followingIds.count
        guard updateUser(owner) else { return false }

        if var target = user(userId: targetUserId) {
            if !target.fanIds.contains(ownerUserId) {
                target.fanIds.append(ownerUserId)
                target.fanCount = target.fanIds.count
                updateUser(target)
            }
        }
        return true
    }

    @discardableResult
    func unfollowUser(ownerUserId: String, targetUserId: String) -> Bool {
        guard var owner = user(userId: ownerUserId) else { return false }
        let before = owner.followingIds.count
        owner.followingIds.removeAll { $0 == targetUserId }
        guard owner.followingIds.count != before else { return true }

        owner.followCount = owner.followingIds.count
        guard updateUser(owner) else { return false }

        if var target = user(userId: targetUserId) {
            target.fanIds.removeAll { $0 == ownerUserId }
            target.fanCount = target.fanIds.count
            updateUser(target)
        }
        return true
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
        badgeInfo: EP_BadgeModel? = nil
    ) -> Bool {
        guard var user = user(userId: userId) else { return false }
        if let name { user.name = name }
        if let avatar { user.avatar = avatar }
        if let isBlock { user.isBlock = isBlock }
        if let followCount { user.followCount = followCount }
        if let fanCount { user.fanCount = fanCount }
        if let coins { user.coins = coins }
        if let badgeInfo { user.badgeInfo = badgeInfo }
        return updateUser(user)
    }

    @discardableResult
    func incrementBadgePush(userId: String) -> Bool {
        guard var user = user(userId: userId) else { return false }
        user.badgeInfo.recordPublish()
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
            img: post.img,
            video: post.video,
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
            img: post.img,
            video: post.video,
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
        syncSeedPostsMediaIfNeeded()
        syncTestUserProfileFromSeedIfNeeded()
        syncTestUserBadgeInfoFromSeedIfNeeded()
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
        guard var test = user(userId: Self.testUserId) else { return }
        let seedTest = Self.buildTestUser()
        var changed = false
        if test.email.isEmpty || test.password.isEmpty {
            test.email = Self.testAccountEmail
            test.password = Self.testAccountPassword
            changed = true
        }
        if changed {
            updateUser(test)
        }
    }

    /// 将 test 用户的关注/粉丝等与 `buildTestUser()` 种子对齐（改种子后本地旧 JSON 会自动更新）
    private func syncTestUserProfileFromSeedIfNeeded() {
        guard var test = user(userId: Self.testUserId) else { return }
        let seedTest = Self.buildTestUser()
        var changed = false

        if test.followingIds != seedTest.followingIds {
            test.followingIds = seedTest.followingIds
            changed = true
        }
        if test.fanIds != seedTest.fanIds {
            test.fanIds = seedTest.fanIds
            changed = true
        }
        if test.followCount != seedTest.followCount {
            test.followCount = seedTest.followCount
            changed = true
        }
        if test.fanCount != seedTest.fanCount {
            test.fanCount = seedTest.fanCount
            changed = true
        }
        if test.blockedUserIds != seedTest.blockedUserIds {
            test.blockedUserIds = seedTest.blockedUserIds
            changed = true
        }
        if changed {
            updateUser(test)
        }
    }

    /// test 用户 badge 与种子对齐（改种子或旧迁移错误数据后自动修正）
    private func syncTestUserBadgeInfoFromSeedIfNeeded() {
        guard var test = user(userId: Self.testUserId) else { return }
        let seedInfo = Self.buildTestUser().badgeInfo
        var info = test.badgeInfo
        var changed = false

        // push 只补种子下限，保留用户发更多帖后的累计
        if info.push < seedInfo.push {
            info.push = seedInfo.push
            changed = true
        }

        // receive / gain 与种子保持一致（旧数据曾把 receive 写成帖子 like 合计导致显示 20/20）
        if info.receive != seedInfo.receive {
            info.receive = seedInfo.receive
            changed = true
        }
        if info.gain != seedInfo.gain {
            info.gain = seedInfo.gain
            changed = true
        }

        if changed {
            test.badgeInfo = info
            updateUser(test)
        }
    }

    /// 将 seed 中帖子的 img / video 与本地对齐（含你改 seed 后仍显示旧封面的情况）
    private func syncSeedPostsMediaIfNeeded() {
        var changed = false
        for seedUser in Self.seedDatabase.users {
            guard let userIndex = database.users.firstIndex(where: { $0.userId == seedUser.userId }) else {
                continue
            }
            for seedPost in seedUser.posts {
                if let postIndex = database.users[userIndex].posts.firstIndex(where: { $0.postId == seedPost.postId }) {
                    var local = database.users[userIndex].posts[postIndex]
                    var postChanged = false
                    if local.video != seedPost.video {
                        local.video = seedPost.video
                        postChanged = true
                    }
                    if local.img != seedPost.img {
                        local.img = seedPost.img
                        postChanged = true
                    }
                    if postChanged {
                        database.users[userIndex].posts[postIndex] = local
                        changed = true
                    }
                } else if !seedPost.video.isEmpty || !seedPost.img.isEmpty {
                    database.users[userIndex].posts.append(seedPost)
                    changed = true
                }
            }
        }
        if changed {
            save()
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
            followCount: 2,
            fanCount: 4,
            followingIds: ["u001", "u002"],
            fanIds: ["u001", "u002", "u003", "u004"],
            blockedUserIds: [],
            coins: 100,
            badgeInfo: EP_BadgeModel(remain: 50, push: 2, receive: 8, gain: 2),
            posts: [
                EP_PostModel(
                    postId: "p_test_01",
                    userId: testUserId,
                    authorName: "Test",
                    authorAvatar: "avatar_05",
                    coverImage: "post_temp",
                    img: "friend_01",
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
                    video: "video_02",
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
            img: String = "",
            video: String = "",
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
                img: img,
                video: video,
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
                name: "Marce",
                avatar: "avatar_01",
                isBlock: false,
                followCount: 22,
                fanCount: 22,
                coins: 120,
                badgeInfo: EP_BadgeModel(remain: 70, push: 2, receive: 12, gain: 22),
                posts: [
                    makePost(
                        postId: "p001",
                        userId: "u001",
                        authorName: "Marce",
                        authorAvatar: "avatar_01",
                        content: "How's my outfit?How's my outfit?",
                        img: "friend_04",
                        isLiked: true,
                        commentCount: 2
                    ),
                    makePost(
                        postId: "p002",
                        userId: "u001",
                        authorName: "Marce",
                        authorAvatar: "avatar_01",
                        content: "Pink vibes today.",
                        video: "video_04",
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
                badgeInfo: EP_BadgeModel(remain: 100, push: 2, receive: 15, gain: 35),
                posts: [
                    makePost(
                        postId: "p003",
                        userId: "u002",
                        authorName: "Street",
                        authorAvatar: "avatar_02",
                        content: "Street style check.",
                        img: "friend_02",
                        isLiked: true,
                        commentCount: 3
                    ),
                    makePost(
                        postId: "p004",
                        userId: "u002",
                        authorName: "Street",
                        authorAvatar: "avatar_02",
                        content: "New cosplay wip.",
                        video: "video_01",
                        commentCount: 1
                    ),
                ]
            ),
            EP_UserModel(
                userId: "u003",
                name: "Thom",
                avatar: "avatar_04",
                isBlock: false,
                followCount: 10,
                fanCount: 12,
                coins: 50,
                badgeInfo: EP_BadgeModel(remain: 30, push: 2, receive: 10, gain: 12),
                posts: [
                    makePost(
                        postId: "p005",
                        userId: "u003",
                        authorName: "Thom",
                        authorAvatar: "avatar_04",
                        content: "Do you like my cosplay outfit?",
                        img: "friend_03",
                        commentCount: 2
                    ),
                    makePost(
                        postId: "p008",
                        userId: "u003",
                        authorName: "Thom",
                        authorAvatar: "avatar_04",
                        content: "I'm about to go on stage, I'm so nervous!",
                        video: "video_06",
                        commentCount: 2
                    ),
                ]
            ),
            EP_UserModel(
                userId: "u004",
                name: "Nana",
                avatar: "avatar_03",
                isBlock: false,
                followCount: 30,
                fanCount: 40,
                coins: 200,
                badgeInfo: EP_BadgeModel(remain: 10, push: 2, receive: 8, gain: 40),
                posts: [
                    makePost(
                        postId: "p006",
                        userId: "u004",
                        authorName: "Nana",
                        authorAvatar: "avatar_04",
                        content: "He's so handsome! I love him so much! Does anyone know who he is? I really want his contact information~",
                        img: "friend_05",
                        commentCount: 1
                    ),
                    makePost(
                        postId: "p007",
                        userId: "u004",
                        authorName: "Nana",
                        authorAvatar: "avatar_03",
                        content: "Thanks for all the likes!",
                        video: "video_03",
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
