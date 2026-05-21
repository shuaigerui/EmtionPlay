//
//  EP_ChatConversationModel.swift
//  EmtionPlayRp
//

import Foundation

/// 单条聊天消息（本地持久化）
struct EP_ChatStoredMessage: Codable, Equatable {
    let messageId: String
    let isOutgoing: Bool
    let text: String
    let avatarImageName: String
    let createdAt: TimeInterval

    init(
        messageId: String = UUID().uuidString,
        isOutgoing: Bool,
        text: String,
        avatarImageName: String,
        createdAt: TimeInterval = Date().timeIntervalSince1970
    ) {
        self.messageId = messageId
        self.isOutgoing = isOutgoing
        self.text = text
        self.avatarImageName = avatarImageName
        self.createdAt = createdAt
    }

    var roomItem: EP_RoomMessageItem {
        EP_RoomMessageItem(
            kind: isOutgoing ? .outgoing : .incoming,
            text: text,
            avatarImageName: avatarImageName
        )
    }
}

/// 与某一用户的会话
struct EP_ChatConversation: Codable, Equatable {
    let ownerUserId: String
    let peerUserId: String
    var peerName: String
    var peerAvatar: String
    var messages: [EP_ChatStoredMessage]
    var lastMessageAt: TimeInterval
    var hasUnread: Bool

    var lastMessageText: String {
        messages.last?.text ?? ""
    }

    func listItem() -> EP_ChatMessageItem {
        EP_ChatMessageItem(
            peerUserId: peerUserId,
            avatarImageName: peerAvatar,
            userName: peerName,
            dateText: Date(timeIntervalSince1970: lastMessageAt).ep_chatListDateText(),
            message: lastMessageText,
            hasUnread: hasUnread
        )
    }
}

struct EP_ChatDatabase: Codable, Equatable {
    var conversations: [EP_ChatConversation]
}

extension Date {

    func ep_chatListDateText() -> String {
        formatted(with: "MMMM d, yyyy")
    }
}

extension EP_ChatConversation {

    static func peerId(userId: String?, displayName: String) -> String {
        let trimmedId = userId?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !trimmedId.isEmpty { return trimmedId }
        return "name_\(displayName.lowercased())"
    }
}
