//
//  EP_BadgeModel.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/20.
//

import Foundation

struct EP_BadgeModel: Codable, Equatable {

    var remain: Int
    var push: Int
    var receive: Int
    var gain: Int

    static let preview = EP_BadgeModel(
        remain: 200,
        push: 10,
        receive: 4,
        gain: 6
    )
}
