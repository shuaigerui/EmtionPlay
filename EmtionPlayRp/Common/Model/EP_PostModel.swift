//
//  EP_PostModel.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/20.
//

import Foundation

/// 帖子评论
struct EP_PostCommentModel: Codable, Equatable {
    let commentId: String
    let userId: String
    var userName: String
    var avatar: String
    var content: String
    /// 展示用时间文案，如 "An hour ago"
    var createdAtText: String

    static let preview = EP_PostCommentModel(
        commentId: "c001",
        userId: "10002",
        userName: "Nana",
        avatar: "home_top",
        content: "An hour agoAn hour agoAn hour agoAn hour agoAn hour ago",
        createdAtText: "An hour ago"
    )
}

/// 帖子详情 / 列表统一数据模型
struct EP_PostModel: Codable, Equatable {
    let postId: String
    let userId: String
    var authorName: String
    var authorAvatar: String
    var coverImage: String
    var content: String
    var isLiked: Bool
    var likeCount: Int
    var commentCount: Int
    var comments: [EP_PostCommentModel]

    static let preview = EP_PostModel(
        postId: "p001",
        userId: "10003",
        authorName: "The non",
        authorAvatar: "home_top",
        coverImage: "post_temp",
        content: "How's my outfit?How's my outfit?How's my outfit?How's my outfit?",
        isLiked: false,
        likeCount: 0,
        commentCount: 3,
        comments: Array(repeating: .preview, count: 3)
    )
}

// MARK: - UI 映射（与现有 Cell / Header 兼容）

extension EP_PostModel {

    var feedItem: EP_PostFeedItem {
        EP_PostFeedItem(
            coverImageName: coverImage,
            avatarImageName: authorAvatar,
            userName: authorName,
            content: content,
            isLiked: isLiked
        )
    }

    var detailCommentItems: [EP_DetailCommentItem] {
        comments.map(\.detailItem)
    }
}

extension EP_PostCommentModel {

    var detailItem: EP_DetailCommentItem {
        EP_DetailCommentItem(
            avatarImageName: avatar,
            userName: userName,
            content: content
        )
    }
}

extension EP_PostFeedItem {

    func toPostModel(
        postId: String = UUID().uuidString,
        userId: String = "",
        likeCount: Int = 0,
        commentCount: Int = 0,
        comments: [EP_PostCommentModel] = []
    ) -> EP_PostModel {
        EP_PostModel(
            postId: postId,
            userId: userId,
            authorName: userName,
            authorAvatar: avatarImageName,
            coverImage: coverImageName,
            content: content,
            isLiked: isLiked,
            likeCount: likeCount,
            commentCount: commentCount,
            comments: comments
        )
    }
}
