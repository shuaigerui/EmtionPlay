//
//  UIImage+Extension.swift
//  VaultixRp
//

import UIKit

extension UIImage {

    /// 等比缩放，最长边不超过 `maxSide`（头像持久化等与注册页一致）。
    func ss_scaled(maxSide: CGFloat) -> UIImage {
        let maxDim = max(size.width, size.height)
        guard maxDim > maxSide, maxDim > 0 else { return self }
        let scale = maxSide / maxDim
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    /// 裁剪到指定区域（rect 为当前 image 坐标系，考虑 scale）
    func cropped(to rect: CGRect) -> UIImage? {
        let scale = self.scale
        let pixelRect = CGRect(
            x: rect.origin.x * scale,
            y: rect.origin.y * scale,
            width: rect.width * scale,
            height: rect.height * scale
        )
        guard let cg = cgImage,
              let cropped = cg.cropping(to: pixelRect) else { return nil }
        return UIImage(cgImage: cropped, scale: scale, orientation: imageOrientation)
    }

    /// 顺时针旋转 90°，生成新位图
    func rotatedClockwise90() -> UIImage? {
        let size = CGSize(width: self.size.height, height: self.size.width)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = self.scale
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { ctx in
            let c = ctx.cgContext
            c.translateBy(x: size.width, y: 0)
            c.rotate(by: .pi / 2)
            draw(at: .zero)
        }
    }
}
