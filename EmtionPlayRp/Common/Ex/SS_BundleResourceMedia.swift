//
//  SS_BundleResourceMedia.swift
//  SurfingSocialRp
//
//  Created by  mac on 2026/5/8.
//

import AVFoundation
import UIKit

/// 读取工程内 Resource 图片 / 视频。
/// 注意：Xcode 常把文件夹内文件**扁平拷贝到 `.app` 根目录**（无 `Resource/Post` 层级），因此优先在 bundle 根目录按 `baseName.ext` 查找。
enum SS_BundleResourceMedia {

    private static func firstURL(
        baseName: String,
        subdirectories: [String],
        extensions: [String]
    ) -> URL? {
        let bundle = Bundle.main
        // 1) 根目录（与当前工程产物一致：post_07.jpg、video_01.mp4 等直接在 .app 内）
        for ext in extensions {
            if let u = bundle.url(forResource: baseName, withExtension: ext) {
                return u
            }
        }
        // 2) 保留子目录写法，兼容将来改为 folder reference 不打平的情况
        for sub in subdirectories {
            for ext in extensions {
                if let u = bundle.url(forResource: baseName, withExtension: ext, subdirectory: sub) {
                    return u
                }
            }
        }
        // 3) 手动拼路径
        let root = bundle.bundleURL
        for sub in subdirectories {
            var dir = root
            if !sub.isEmpty {
                dir = dir.appendingPathComponent(sub)
            }
            for ext in extensions {
                let u = dir.appendingPathComponent("\(baseName).\(ext)")
                if FileManager.default.fileExists(atPath: u.path) {
                    return u
                }
            }
        }
        return nil
    }

    /// `Resource/Post` 下的静态图（如 `post_07.jpg` → baseName `post_07`）。
    static func postImageURL(baseName: String) -> URL? {
        firstURL(
            baseName: baseName,
            subdirectories: ["Resource/Post", "Post"],
            extensions: ["jpg", "jpeg", "png"]
        )
    }

    /// `Resource/Video` 下的视频（如 `video_01.mp4`）。
    static func videoURL(baseName: String) -> URL? {
        firstURL(
            baseName: baseName,
            subdirectories: ["Resource/Video", "Video"],
            extensions: ["mp4", "mov", "m4v"]
        )
    }

    /// `Resource/Avatar` 下的头像图。
    static func avatarImageURL(baseName: String) -> URL? {
        firstURL(
            baseName: baseName,
            subdirectories: ["Resource/Avatar", "Avatar"],
            extensions: ["jpg", "jpeg", "png"]
        )
    }

    /// `Resource/Voice` 下的语音（如 `girl_01.mp3`）。
    static func voiceURL(baseName: String) -> URL? {
        firstURL(
            baseName: baseName,
            subdirectories: ["Resource/Voice", "Voice"],
            extensions: ["mp3", "m4a", "wav", "caf"]
        )
    }

    static func uiImage(fileURL: URL) -> UIImage? {
        UIImage(contentsOfFile: fileURL.path)
    }

    static func avatarImage(baseName: String) -> UIImage? {
        guard let url = avatarImageURL(baseName: baseName) else { return nil }
        return uiImage(fileURL: url)
    }

    /// 加载用户头像：`avatarJPEGData` → Resource/Avatar → `UIImage(named:)`。
//    static func loadAvatar(for user: SS_UserModel, completion: @escaping (UIImage?) -> Void) {
//        if let data = user.avatarJPEGData, let img = UIImage(data: data) {
//            DispatchQueue.main.async { completion(img) }
//            return
//        }
//        guard let name = user.avatarAssetName, !name.isEmpty else {
//            DispatchQueue.main.async { completion(nil) }
//            return
//        }
//        DispatchQueue.global(qos: .userInitiated).async {
//            let img =
//                Self.avatarImageURL(baseName: name)
//                .flatMap { Self.uiImage(fileURL: $0) }
//                ?? UIImage(named: name)
//            DispatchQueue.main.async { completion(img) }
//        }
//    }

    /// 取视频第一帧作为封面（异步调用建议在后台队列执行）。
    static func videoFirstFrame(url: URL, maxDimension: CGFloat = 720) -> UIImage? {
        let asset = AVURLAsset(url: url)
        let gen = AVAssetImageGenerator(asset: asset)
        gen.appliesPreferredTrackTransform = true
        gen.maximumSize = CGSize(width: maxDimension, height: maxDimension)
        let time = CMTime(seconds: 0, preferredTimescale: 600)
        do {
            let cgImage = try gen.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            return nil
        }
    }
}
