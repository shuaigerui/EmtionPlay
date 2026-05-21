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

    /// 隐藏帖子（写入当前用户 hiddenPostIds）
    @discardableResult
    func ep_hidePost(postId: String) -> Bool {
        guard let ownerId = EP_CurrentUser.shared.user?.userId else { return false }
        guard UserData.shared.hidePost(postId: postId, ownerUserId: ownerId) else { return false }
        EP_CurrentUser.shared.refreshFromDatabase()
        return true
    }

    /// 拉黑用户（仅个人页 header 等场景使用）
    @discardableResult
    func ep_blockUser(userId: String) -> Bool {
        guard !userId.isEmpty, let ownerId = EP_CurrentUser.shared.user?.userId else { return false }
        guard UserData.shared.setUserBlock(userId: userId, isBlock: true, ownerUserId: ownerId) else {
            return false
        }
        EP_CurrentUser.shared.refreshFromDatabase()
        return true
    }
}
