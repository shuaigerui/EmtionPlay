//
//  String+Localization.swift
//  SecurePixRp
//
//  Created by  mac on 2026/2/27.
//

import Foundation

public extension String {
    /// Returns the localized string from Localizable.strings in the main bundle
    var localization: String {
        return NSLocalizedString(self, comment: "")
    }

    /// Returns the localized string with format arguments (like String(format:))
    /// Example: "welcome_message %@".localized(with: username)
    func localized(with arguments: CVarArg...) -> String {
        let format = NSLocalizedString(self, comment: "")
        return String(format: format, arguments: arguments)
    }
}

// MARK: - Language Management
class LanguageManager {
    static let shared = LanguageManager()
    
    private init() {}
    
    /// 获取当前应用语言
    func getCurrentLanguage() -> String {
        if let savedLanguage = UserDefaults.standard.string(forKey: "AppLanguage") {
            return savedLanguage
        }
        
        // 如果没有保存的语言设置，使用系统语言
        let systemLanguage = Locale.current.languageCode ?? "en"
        return systemLanguage
    }
    
    /// 设置应用语言
    func setLanguage(_ languageCode: String) {
        print("🌐 [LanguageManager] 设置语言: \(languageCode)")
        let previousLanguage = getCurrentLanguage()
        print("🌐 [LanguageManager] 之前的语言: \(previousLanguage)")
        
        UserDefaults.standard.set(languageCode, forKey: "AppLanguage")
        UserDefaults.standard.synchronize()
        
        // 验证保存是否成功
        if let saved = UserDefaults.standard.string(forKey: "AppLanguage") {
            print("🌐 [LanguageManager] 语言已保存: \(saved)")
        } else {
            print("❌ [LanguageManager] 语言保存失败！")
        }
        
        // 发送语言变更通知
        NotificationCenter.default.post(name: .languageChanged, object: languageCode)
        print("🌐 [LanguageManager] 已发送语言变更通知")
    }
    
    /// 获取本地化字符串（支持动态语言切换）
    func localizedString(for key: String) -> String {
        let currentLanguage = getCurrentLanguage()
        
        // 获取对应语言的bundle
        guard let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj") else {
            print("⚠️ [LanguageManager] 找不到语言 bundle 路径: \(currentLanguage).lproj")
            // 如果找不到对应语言的bundle，使用默认的NSLocalizedString
            let result = NSLocalizedString(key, comment: "")
            print("⚠️ [LanguageManager] 使用默认本地化: key=\(key), result=\(result)")
            return result
        }
        
        guard let bundle = Bundle(path: path) else {
            print("⚠️ [LanguageManager] 无法创建 bundle: \(path)")
            let result = NSLocalizedString(key, comment: "")
            return result
        }
        
        let result = NSLocalizedString(key, bundle: bundle, comment: "")
        // 只在调试时打印（避免日志过多）
        if result == key {
            print("⚠️ [LanguageManager] 未找到本地化字符串: key=\(key), language=\(currentLanguage), bundle=\(path)")
        }
        return result
    }
    
    /// 获取所有可用的语言列表（从 .lproj 目录动态获取）
    func getAvailableLanguages() -> [(code: String, name: String)] {
        var languages: [(code: String, name: String)] = []
        
        // 语言代码到原生名称的映射（用于那些无法通过 Locale 正确获取的语言）
        let languageNameMap: [String: String] = [
            "ar": "العربية",      // 阿拉伯语
            "en": "English",       // 英语
            "es": "Español",       // 西班牙语
            "fr": "Français",      // 法语
            "hi": "हिंदी",          // 印地语
            "ja": "日本語",         // 日语
            "ko": "한국어",         // 韩语
            "pt": "Português",     // 葡萄牙语
            "vi": "Tiếng Việt",    // 越南语
            "ru": "Русский"        // 俄语
        ]
        
        // 使用 Bundle.main.localizations 获取所有可用的本地化语言（这是 iOS 提供的标准方法）
        let availableLanguageCodes = Bundle.main.localizations.filter { $0 != "Base" }
        
        // 提取语言代码并获取语言名称
        for languageCode in availableLanguageCodes {
            // 优先使用映射表中的名称
            let displayName: String
            if let mappedName = languageNameMap[languageCode] {
                displayName = mappedName
            } else {
                // 如果没有映射，尝试使用 Locale 获取
                let locale = Locale(identifier: languageCode)
                if let localeName = locale.localizedString(forLanguageCode: languageCode),
                   localeName != languageCode {
                    displayName = localeName
                } else {
                    // 如果还是获取不到，使用语言代码本身
                    displayName = languageCode.uppercased()
                }
            }
            
            languages.append((code: languageCode, name: displayName))
        }
        
        // 按语言代码排序
        languages.sort { $0.code < $1.code }
        
        return languages
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let languageChanged = Notification.Name("LanguageChanged")
}

// MARK: - Enhanced String Extension
public extension String {
    /// 使用LanguageManager获取本地化字符串
    var localized: String {
        return LanguageManager.shared.localizedString(for: self)
    }
}
