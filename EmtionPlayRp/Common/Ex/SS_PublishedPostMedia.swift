//
//  SS_PublishedPostMedia.swift
//  SurfingSocialRp
//

import Foundation
import UIKit

/// 用户发帖保存到沙盒的媒体（`baseName` 无扩展名，与 bundle 内帖子字段一致）。
enum SS_PublishedPostMedia {

    private static let folderName = "PublishedPostMedia"

    static func mediaDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(folderName, isDirectory: true)
    }

    private static func ensureDirectory() {
        let url = mediaDirectory()
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }

    /// 返回写入文件的 **baseName**（不含扩展名），写入 `baseName.jpg`。
    static func savePhoto(_ image: UIImage) -> String? {
        ensureDirectory()
        guard let data = image.jpegData(compressionQuality: 0.88) else { return nil }
        let base = "p_\(UUID().uuidString)"
        let fileURL = mediaDirectory().appendingPathComponent("\(base).jpg")
        do {
            try data.write(to: fileURL, options: .atomic)
            return base
        } catch {
            return nil
        }
    }

    /// 拷贝相册视频到沙盒，返回 **baseName**（无扩展名），文件为 `baseName.mp4`。
    static func saveVideo(from pickedURL: URL) -> String? {
        ensureDirectory()
        let base = "v_\(UUID().uuidString)"
        let dest = mediaDirectory().appendingPathComponent("\(base).mp4")
        do {
            if FileManager.default.fileExists(atPath: dest.path) {
                try FileManager.default.removeItem(at: dest)
            }
            try FileManager.default.copyItem(at: pickedURL, to: dest)
            return base
        } catch {
            return nil
        }
    }

    static func imageFileURL(baseName: String) -> URL? {
        for ext in ["jpg", "jpeg", "png"] {
            let u = mediaDirectory().appendingPathComponent("\(baseName).\(ext)")
            if FileManager.default.fileExists(atPath: u.path) { return u }
        }
        return nil
    }

    static func videoFileURL(baseName: String) -> URL? {
        for ext in ["mp4", "mov", "m4v"] {
            let u = mediaDirectory().appendingPathComponent("\(baseName).\(ext)")
            if FileManager.default.fileExists(atPath: u.path) { return u }
        }
        return nil
    }

    /// 删除沙盒内与该帖关联的媒体（bundle 资源无对应文件则忽略）。
//    static func removeMediaFiles(for post: SS_PostModel) {
//        for base in post.imgs {
//            if let u = imageFileURL(baseName: base) {
//                try? FileManager.default.removeItem(at: u)
//            }
//        }
//        if let v = post.video, let u = videoFileURL(baseName: v) {
//            try? FileManager.default.removeItem(at: u)
//        }
//    }
}

extension SS_BundleResourceMedia {

    /// 优先沙盒用户发帖图片，再 bundle `Resource/Post`。
    static func resolvePostImageURL(baseName: String) -> URL? {
        SS_PublishedPostMedia.imageFileURL(baseName: baseName) ?? postImageURL(baseName: baseName)
    }

    /// 优先沙盒用户发帖视频，再 bundle `Resource/Video`。
    static func resolveVideoURL(baseName: String) -> URL? {
        SS_PublishedPostMedia.videoFileURL(baseName: baseName) ?? videoURL(baseName: baseName)
    }
}
