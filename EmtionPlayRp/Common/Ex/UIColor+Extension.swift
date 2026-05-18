//
//  UIColor+Extension.swift
//  SecurePixRp
//
//  Created by  mac on 2026/2/27.
//

import UIKit

extension UIColor {

    /// 随机颜色
    class var randomColor: UIColor {
        get {
            let red = CGFloat(arc4random()%256)/255.0
            let green = CGFloat(arc4random()%256)/255.0
            let blue = CGFloat(arc4random()%256)/255.0
            return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        }
    }
    
    class func color(hexString: String, alpha: CGFloat = 1.0) -> UIColor {
        var cString : String = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if cString.count < 6 {
            return UIColor.black
        }
        
        if cString.hasPrefix("0X"){
            cString = NSString(string: cString).substring(from: 2)
        }
        if cString.hasPrefix("#"){
            cString = NSString(string: cString).substring(from: 1)
        }
        if cString.count != 6{
            return UIColor.black
        }
        // Separate into r, g, b substrings
        var range  = NSRange(location: 0,length: 2)
        let rString = NSString(string: cString).substring(with: range)
        range.location = 2
        let gString = NSString(string: cString).substring(with: range)
        range.location = 4
        let bString = NSString(string: cString).substring(with: range)
        
        // Scan values
        var r, g, b : UInt64?
        r = 0
        g = 0
        b = 0
        Scanner(string: rString).scanHexInt64(&r!)
        Scanner(string: gString).scanHexInt64(&g!)
        Scanner(string: bString).scanHexInt64(&b!)
        
        return UIColor(red: (CGFloat(r!))/255.0, green: (CGFloat(g!))/255.0, blue: (CGFloat(b!))/255.0, alpha: alpha)
    }
    
    func alpha(_ alpha: CGFloat) -> UIColor {
        return self.withAlphaComponent(alpha)
    }
}
