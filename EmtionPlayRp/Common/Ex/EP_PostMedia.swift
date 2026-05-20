//
//  EP_PostMedia.swift
//  EmtionPlayRp
//

import UIKit

/// 帖子 `img` / `video` 路径解析：Resource/Friend、Resource/Video、相册沙盒。
enum EP_PostMedia {

    /// 帖子封面：有视频取首帧；否则用 `img`；最后回退 `coverImage`。
    static func coverImage(img: String, video: String, fallbackCover: String = "") -> UIImage? {
        if !video.isEmpty, let url = resolveVideoURL(video) {
            if let frame = SS_BundleResourceMedia.videoFirstFrame(url: url) {
                return frame
            }
        }
        if !img.isEmpty {
            if let url = resolveImageURL(img), let image = SS_BundleResourceMedia.uiImage(fileURL: url) {
                return image
            }
            return UIImage.ep_named(img)
        }
        guard !fallbackCover.isEmpty else { return nil }
        return UIImage.ep_named(fallbackCover)
    }

    static func coverImage(for post: EP_PostModel) -> UIImage? {
        coverImage(img: post.img, video: post.video, fallbackCover: post.coverImage)
    }

    static func resolveImageURL(_ img: String) -> URL? {
        guard !img.isEmpty else { return nil }
        if img.hasPrefix("/") {
            let url = URL(fileURLWithPath: img)
            return FileManager.default.fileExists(atPath: url.path) ? url : nil
        }
        if img.hasPrefix("p_") {
            return SS_PublishedPostMedia.imageFileURL(baseName: img)
        }
        return SS_BundleResourceMedia.friendImageURL(baseName: img)
            ?? SS_PublishedPostMedia.imageFileURL(baseName: img)
            ?? SS_BundleResourceMedia.postImageURL(baseName: img)
    }

    static func resolveVideoURL(_ video: String) -> URL? {
        guard !video.isEmpty else { return nil }
        if video.hasPrefix("/") {
            let url = URL(fileURLWithPath: video)
            return FileManager.default.fileExists(atPath: url.path) ? url : nil
        }
        return SS_BundleResourceMedia.resolveVideoURL(baseName: video)
    }
}
