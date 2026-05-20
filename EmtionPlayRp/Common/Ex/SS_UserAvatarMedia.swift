//
//  SS_UserAvatarMedia.swift
//  VoiceEmotionalRp
//

import UIKit

/// 用户自定义头像（沙盒 `Documents/UserAvatars`，`baseName` 无扩展名）。
enum SS_UserAvatarMedia {

    private static let folderName = "UserAvatars"

    static func mediaDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(folderName, isDirectory: true)
    }

    private static func ensureDirectory() {
        let url = mediaDirectory()
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }

    /// 覆盖保存当前用户头像，返回 **baseName**（如 `av_9000`）。
    static func saveAvatar(_ image: UIImage, userId: Int64) -> String? {
        saveAvatar(image, userId: "\(userId)")
    }

    /// 覆盖保存当前用户头像（字符串 userId），返回 **baseName**（如 `av_u_test`）。
    static func saveAvatar(_ image: UIImage, userId: String) -> String? {
        ensureDirectory()
        guard let data = image.jpegData(compressionQuality: 0.88) else { return nil }
        let base = "av_\(userId)"
        let fileURL = mediaDirectory().appendingPathComponent("\(base).jpg")
        do {
            try data.write(to: fileURL, options: .atomic)
            return base
        } catch {
            return nil
        }
    }

    /// 删除 `av_{userId}` 沙盒头像（若存在）。
    static func removeSavedAvatarIfPresent(userId: Int64) {
        let base = "av_\(userId)"
        guard let url = imageFileURL(baseName: base) else { return }
        try? FileManager.default.removeItem(at: url)
    }

    static func imageFileURL(baseName: String) -> URL? {
        for ext in ["jpg", "jpeg", "png"] {
            let u = mediaDirectory().appendingPathComponent("\(baseName).\(ext)")
            if FileManager.default.fileExists(atPath: u.path) { return u }
        }
        return nil
    }

    static func uiImage(baseName: String) -> UIImage? {
        guard let url = imageFileURL(baseName: baseName) else { return nil }
        return UIImage(contentsOfFile: url.path)
    }
}
