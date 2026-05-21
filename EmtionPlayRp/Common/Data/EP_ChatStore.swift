//
//  EP_ChatStore.swift
//  EmtionPlayRp
//

import Foundation

/// 本地聊天会话与消息持久化
final class EP_ChatStore {

    static let shared = EP_ChatStore()

    private let fileName = "ep_chat_conversations.json"
    private var database: EP_ChatDatabase

    private init() {
        database = Self.loadFromDisk(fileName: fileName) ?? EP_ChatDatabase(conversations: [])
    }

    // MARK: - 查询

    func listItems(ownerUserId: String) -> [EP_ChatMessageItem] {
        database.conversations
            .filter { $0.ownerUserId == ownerUserId }
            .sorted { $0.lastMessageAt > $1.lastMessageAt }
            .map { $0.listItem() }
    }

    func roomMessages(ownerUserId: String, peerUserId: String) -> [EP_RoomMessageItem] {
        conversation(ownerUserId: ownerUserId, peerUserId: peerUserId)?
            .messages
            .map(\.roomItem) ?? []
    }

    func conversation(ownerUserId: String, peerUserId: String) -> EP_ChatConversation? {
        database.conversations.first {
            $0.ownerUserId == ownerUserId && $0.peerUserId == peerUserId
        }
    }

    // MARK: - 写入

    @discardableResult
    func appendMessage(
        ownerUserId: String,
        peerUserId: String,
        peerName: String,
        peerAvatar: String,
        text: String,
        isOutgoing: Bool,
        senderAvatar: String
    ) -> EP_ChatStoredMessage? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !ownerUserId.isEmpty, !peerUserId.isEmpty else { return nil }

        let message = EP_ChatStoredMessage(
            isOutgoing: isOutgoing,
            text: trimmed,
            avatarImageName: senderAvatar
        )
        let now = message.createdAt

        if let index = database.conversations.firstIndex(where: {
            $0.ownerUserId == ownerUserId && $0.peerUserId == peerUserId
        }) {
            database.conversations[index].messages.append(message)
            database.conversations[index].lastMessageAt = now
            database.conversations[index].peerName = peerName
            database.conversations[index].peerAvatar = peerAvatar
            if isOutgoing {
                database.conversations[index].hasUnread = false
            }
        } else {
            let conversation = EP_ChatConversation(
                ownerUserId: ownerUserId,
                peerUserId: peerUserId,
                peerName: peerName,
                peerAvatar: peerAvatar,
                messages: [message],
                lastMessageAt: now,
                hasUnread: !isOutgoing
            )
            database.conversations.append(conversation)
        }

        save()
        return message
    }

    func markAsRead(ownerUserId: String, peerUserId: String) {
        guard let index = database.conversations.firstIndex(where: {
            $0.ownerUserId == ownerUserId && $0.peerUserId == peerUserId
        }) else { return }
        guard database.conversations[index].hasUnread else { return }
        database.conversations[index].hasUnread = false
        save()
    }

    func deleteConversation(ownerUserId: String, peerUserId: String) {
        let before = database.conversations.count
        database.conversations.removeAll {
            $0.ownerUserId == ownerUserId && $0.peerUserId == peerUserId
        }
        guard database.conversations.count != before else { return }
        save()
    }

    /// 删除与指定用户相关的全部会话（注销账号）
    func deleteAllForUser(userId: String) {
        guard !userId.isEmpty else { return }
        let before = database.conversations.count
        database.conversations.removeAll {
            $0.ownerUserId == userId || $0.peerUserId == userId
        }
        guard database.conversations.count != before else { return }
        save()
    }

    func reload() {
        database = Self.loadFromDisk(fileName: fileName) ?? EP_ChatDatabase(conversations: [])
    }

    // MARK: - 持久化

    private func save() {
        Self.saveToDisk(database, fileName: fileName)
    }

    private static func loadFromDisk(fileName: String) -> EP_ChatDatabase? {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent(fileName)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(EP_ChatDatabase.self, from: data)
    }

    private static func saveToDisk(_ database: EP_ChatDatabase, fileName: String) {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent(fileName)
        guard let data = try? JSONEncoder().encode(database) else { return }
        try? data.write(to: url, options: .atomic)
    }
}
