//
//  EP_BadgeModel.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/20.
//

import Foundation

struct EP_BadgeModel: Codable, Equatable {

    /// 当前徽章能量（进度条分子）
    var remain: Int
    /// 发布动态次数
    var push: Int
    /// 收到点赞累计
    var receive: Int
    /// 获得粉丝累计（任务进度，可与 fanCount 分别维护）
    var gain: Int

    static let legendThreshold = 100
    static let pushGoal = 10
    static let receiveGoal = 20
    static let gainGoal = 10

    static let empty = EP_BadgeModel(remain: 0, push: 0, receive: 0, gain: 0)

    static let preview = EP_BadgeModel(
        remain: 50,
        push: 2,
        receive: 8,
        gain: 4
    )

    mutating func recordPublish() {
        push += 1
    }

    /// 个人页头像旁展示的已达最高档勋章图（未达 20 返回 nil）
    var profileBadgeImageName: String? {
        if remain >= Self.legendThreshold { return "badge_legend_sel" }
        if remain >= 60 { return "badge_star_sel" }
        if remain >= 20 { return "badge_dimen_sel" }
        return nil
    }
}
