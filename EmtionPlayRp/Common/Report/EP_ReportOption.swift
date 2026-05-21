//
//  EP_ReportOption.swift
//  EmtionPlayRp
//

import Foundation

/// 举报类型（对应 Assets/Report 图片资源）
enum EP_ReportOption: Int, CaseIterable {
    case pornographic
    case verbalViolence
    case religiousDiscrimination
    case contentError
    case genderDiscrimination
    case block

    var imageName: String {
        switch self {
        case .pornographic: return "report_porn"
        case .verbalViolence: return "report_verbal"
        case .religiousDiscrimination: return "report_relig"
        case .contentError: return "report_content"
        case .genderDiscrimination: return "report_gender"
        case .block: return "report_block"
        }
    }
}
