//
//  UIViewController+EPReport.swift
//  EmtionPlayRp
//

import UIKit

extension UIViewController {

    /// 弹出举报底部 sheet
    func ep_presentReportSheet(onConfirm: ((EP_ReportOption) -> Void)? = nil) {
        let sheet = EP_ReportSheetVC()
        sheet.onConfirm = onConfirm
        sheet.modalPresentationStyle = .overFullScreen
        present(sheet, animated: false)
    }
}
