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
    /// 列表封面回退图（Assets 名，如 post_temp）
    var coverImage: String
    /// 图片：bundle `Resource/Friend` 的 baseName（如 friend_01），或沙盒 baseName（p_xxx）、或相册绝对路径
    var img: String
    /// 视频：bundle `Resource/Video` 的 baseName（如 video_01），或沙盒 baseName（v_xxx）、或相册绝对路径；展示时取首帧
    var video: String
    var content: String
    var isLiked: Bool
    var likeCount: Int
    var commentCount: Int
    var comments: [EP_PostCommentModel]

    init(
        postId: String,
        userId: String,
        authorName: String,
        authorAvatar: String,
        coverImage: String = "post_temp",
        img: String = "",
        video: String = "",
        content: String,
        isLiked: Bool,
        likeCount: Int,
        commentCount: Int,
        comments: [EP_PostCommentModel] = []
    ) {
        self.postId = postId
        self.userId = userId
        self.authorName = authorName
        self.authorAvatar = authorAvatar
        self.coverImage = coverImage
        self.img = img
        self.video = video
        self.content = content
        self.isLiked = isLiked
        self.likeCount = likeCount
        self.commentCount = commentCount
        self.comments = comments
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        postId = try container.decode(String.self, forKey: .postId)
        userId = try container.decode(String.self, forKey: .userId)
        authorName = try container.decode(String.self, forKey: .authorName)
        authorAvatar = try container.decode(String.self, forKey: .authorAvatar)
        coverImage = try container.decodeIfPresent(String.self, forKey: .coverImage) ?? "post_temp"
        img = try container.decodeIfPresent(String.self, forKey: .img) ?? ""
        video = try container.decodeIfPresent(String.self, forKey: .video) ?? ""
        content = try container.decode(String.self, forKey: .content)
        isLiked = try container.decode(Bool.self, forKey: .isLiked)
        likeCount = try container.decode(Int.self, forKey: .likeCount)
        commentCount = try container.decode(Int.self, forKey: .commentCount)
        comments = try container.decodeIfPresent([EP_PostCommentModel].self, forKey: .comments) ?? []
    }

    private enum CodingKeys: String, CodingKey {
        case postId, userId, authorName, authorAvatar, coverImage, img, video
        case content, isLiked, likeCount, commentCount, comments
    }

    static let preview = EP_PostModel(
        postId: "p001",
        userId: "10003",
        authorName: "The non",
        authorAvatar: "home_top",
        coverImage: "post_temp",
        img: "friend_01",
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
            userId: userId,
            coverImageName: coverImage,
            img: img,
            video: video,
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
            img: img,
            video: video,
            content: content,
            isLiked: isLiked,
            likeCount: likeCount,
            commentCount: commentCount,
            comments: comments
        )
    }
}
