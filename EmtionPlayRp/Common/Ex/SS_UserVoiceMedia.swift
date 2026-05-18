//
//  SS_UserVoiceMedia.swift
//  VoiceEmotionalRp
//

import Foundation

/// 用户录制语音（沙盒 `Documents/UserVoices`，`baseName` 无扩展名，文件为 `.m4a`）。
enum SS_UserVoiceMedia {

    private static let folderName = "UserVoices"

    static func mediaDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(folderName, isDirectory: true)
    }

    private static func ensureDirectory() {
        let url = mediaDirectory()
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }

    /// 将临时录音复制为当前用户语音，返回 **baseName**（如 `uv_9000`）。
    static func saveVoiceCopy(from sourceURL: URL, userId: Int64) -> String? {
        ensureDirectory()
        let base = "uv_\(userId)"
        let dest = mediaDirectory().appendingPathComponent("\(base).m4a")
        do {
            if FileManager.default.fileExists(atPath: dest.path) {
                try FileManager.default.removeItem(at: dest)
            }
            try FileManager.default.copyItem(at: sourceURL, to: dest)
            return base
        } catch {
            return nil
        }
    }

    static func voiceFileURL(baseName: String) -> URL? {
        let u = mediaDirectory().appendingPathComponent("\(baseName).m4a")
        if FileManager.default.fileExists(atPath: u.path) { return u }
        return nil
    }

    /// 删除 `uv_{userId}` 沙盒语音（若存在）。
    static func removeVoiceIfPresent(userId: Int64) {
        let base = "uv_\(userId)"
        guard let url = voiceFileURL(baseName: base) else { return }
        try? FileManager.default.removeItem(at: url)
    }
}
