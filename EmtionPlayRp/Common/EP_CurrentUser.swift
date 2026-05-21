//
//  EP_CurrentUser.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/20.
//

import UIKit

/// 当前登录用户与会话状态（UserDefaults 记录 userId，用户数据来自 UserData）
final class EP_CurrentUser {

    static let shared = EP_CurrentUser()

    static let testEmail = UserData.testAccountEmail
    static let testPassword = UserData.testAccountPassword

    private enum Keys {
        static let isLoggedIn = "ep_is_logged_in"
        static let currentUserId = "ep_current_user_id"
    }

    private(set) var user: EP_UserModel?

    var isLoggedIn: Bool { user != nil }

    private init() {
        restoreSession()
    }

    // MARK: - 登录 / 注册

    @discardableResult
    func signIn(email: String, password: String) -> Bool {
        let normalized = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let pwd = password

        if normalized == Self.testEmail, pwd == Self.testPassword {
            guard let testUser = UserData.shared.testUser else { return false }
            login(with: testUser)
            return true
        }

        if let matched = UserData.shared.user(email: normalized, password: pwd) {
            login(with: matched)
            return true
        }
        return false
    }

    /// 注册新账号并登录
    @discardableResult
    func register(
        email: String,
        password: String,
        name: String,
        avatar: String,
        avatarImage: UIImage? = nil
    ) -> Bool {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalizedEmail.isEmpty, !password.isEmpty else { return false }
        let displayName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !displayName.isEmpty else { return false }

        if normalizedEmail == Self.testEmail {
            return false
        }
        if UserData.shared.user(email: normalizedEmail) != nil {
            return false
        }

        let userId = Self.makeUserId()
        var avatarKey = avatar
        if let image = avatarImage?.ss_scaled(maxSide: 512),
           let saved = SS_UserAvatarMedia.saveAvatar(image, userId: userId) {
            avatarKey = saved
        }

        let newUser = EP_UserModel(
            userId: userId,
            name: displayName,
            avatar: avatarKey,
            email: normalizedEmail,
            password: password,
            isBlock: false,
            followCount: 0,
            fanCount: 0,
            coins: 0,
            badgeInfo: .empty
        )
        guard UserData.shared.addUser(newUser) else { return false }
        login(with: newUser)
        return true
    }

    /// Apple 登录：按 Apple 用户标识创建或恢复本地用户
    @discardableResult
    func signInWithApple(
        appleUserId: String,
        displayName: String?,
        email: String?,
        avatarImage: UIImage? = nil
    ) -> Bool {
        let trimmedAppleId = appleUserId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedAppleId.isEmpty else { return false }

        let trimmedName = displayName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let normalizedEmail = email?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased() ?? ""
        let accountEmail: String
        if normalizedEmail.isEmpty {
            accountEmail = "apple_\(trimmedAppleId)@apple.local"
        } else {
            accountEmail = normalizedEmail
        }

        if let existing = UserData.shared.user(email: accountEmail) {
            login(with: existing)
            return true
        }

        let name = trimmedName.isEmpty ? "Apple User" : trimmedName
        let userId = Self.makeUserId()
        var avatarKey = "avatar_01"
        if let image = avatarImage?.ss_scaled(maxSide: 512),
           let saved = SS_UserAvatarMedia.saveAvatar(image, userId: userId) {
            avatarKey = saved
        }

        let newUser = EP_UserModel(
            userId: userId,
            name: name,
            avatar: avatarKey,
            email: accountEmail,
            password: "",
            isBlock: false,
            followCount: 0,
            fanCount: 0,
            coins: 0,
            badgeInfo: .empty
        )
        guard UserData.shared.addUser(newUser) else { return false }
        login(with: newUser)
        return true
    }

    func logout() {
        user = nil
        clearSessionFlags()
    }

    /// 删除当前账号本地数据并退出登录
    @discardableResult
    func deleteAccountAndSignOut() -> Bool {
        guard let userId = user?.userId else { return false }
        guard UserData.shared.deleteAccount(userId: userId) else { return false }
        logout()
        return true
    }

    /// 注销 / 退出后回到欢迎页
    func switchToWelcomeInterface(animated: Bool = true) {
        guard let window = UIApplication.window else { return }
        let root = UINavigationController(rootViewController: EP_WelcomeVC())
        guard animated else {
            window.rootViewController = root
            return
        }
        UIView.transition(with: window, duration: 0.25, options: .transitionCrossDissolve) {
            window.rootViewController = root
        }
    }

    /// 从本地数据库刷新当前用户
    func refreshFromDatabase() {
        guard let userId = user?.userId,
              let latest = UserData.shared.user(userId: userId) else {
            logout()
            return
        }
        user = latest
    }

    /// 登录成功后切换到主界面
    func switchToMainInterface(animated: Bool = true) {
        guard let window = UIApplication.window else { return }
        let root = EP_TabBarVC()
        guard animated else {
            window.rootViewController = root
            return
        }
        UIView.transition(with: window, duration: 0.25, options: .transitionCrossDissolve) {
            window.rootViewController = root
        }
    }

    // MARK: - Private

    private func login(with user: EP_UserModel) {
        self.user = user
        UserDefaults.standard.set(true, forKey: Keys.isLoggedIn)
        UserDefaults.standard.set(user.userId, forKey: Keys.currentUserId)
    }

    private func restoreSession() {
        guard UserDefaults.standard.bool(forKey: Keys.isLoggedIn),
              let userId = UserDefaults.standard.string(forKey: Keys.currentUserId),
              let stored = UserData.shared.user(userId: userId) else {
            user = nil
            clearSessionFlags()
            return
        }
        user = stored
    }

    private func clearSessionFlags() {
        UserDefaults.standard.set(false, forKey: Keys.isLoggedIn)
        UserDefaults.standard.removeObject(forKey: Keys.currentUserId)
    }

    private static func makeUserId() -> String {
        "u_\(Int(Date().timeIntervalSince1970))_\(UUID().uuidString.prefix(4).lowercased())"
    }
}
