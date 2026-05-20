//
//  String+Extension.swift
//  SecurePixRp
//
//  Created by  mac on 2026/2/27.
//

import UIKit

extension String {
    
    //是否为邮箱
    var isValidEmail: Bool {
        // http://emailregex.com/
        let regex = "^(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])$"
        return range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
    
    // 颜色
    var toColor: UIColor {
        return UIColor.color(hexString: self, alpha: 1.0)
    }
    
    // 图片：Assets → Resource/Avatar → 沙盒用户头像
    var toImage: UIImage? {
        UIImage.ep_named(self)
    }

    /// 仅加载 Resource/Avatar 下头像（如 avatar_01）
    var toAvatarImage: UIImage? {
        UIImage.ep_avatar(self)
    }
    
    var intValue: Int {
        return (self as NSString).integerValue
    }
    
    var isBlank : Bool {
        return allSatisfy({$0.isWhitespace})
    }
    
    var isNewLine: Bool {
        return allSatisfy({$0.isNewline})
    }
    
    var toYear: String {
        if self == "0001-01-01" {
            return ""
        }
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        if let oldDate = format.date(from: self) {
            let currentDate = Date()
            let timeInterval = currentDate.timeIntervalSince(oldDate)
            let time = timeInterval/(3600*24*365)
            return "\(Int(time))"
        }
        return ""
    }
    
}
