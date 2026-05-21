//
//  EP_ChallengeStore.swift
//  EmtionPlayRp
//

import Foundation

/// 挑战榜条目种子数据与当前用户点赞状态（本地持久化）
final class EP_ChallengeStore {

    static let shared = EP_ChallengeStore()

    private struct Seed {
        let challengeId: String
        let coverImageName: String
        let caption: String
        let baseLikeCount: Int
    }

    /// 固定种子：封面 `rank_01`…`rank_08`，点赞数为写死初值（非每次随机）
    private static let seeds: [Seed] = [
        Seed(challengeId: "rank_01", coverImageName: "rank_01", caption: "Princess appears", baseLikeCount: 1284),
        Seed(challengeId: "rank_02", coverImageName: "rank_02", caption: "I want to climb the rankings", baseLikeCount: 2156),
        Seed(challengeId: "rank_03", coverImageName: "rank_03", caption: "How about this?", baseLikeCount: 987),
        Seed(challengeId: "rank_04", coverImageName: "rank_04", caption: "it's been a long time since I dressed up.", baseLikeCount: 1643),
        Seed(challengeId: "rank_05", coverImageName: "rank_05", caption: "What do you all think?", baseLikeCount: 3021),
        Seed(challengeId: "rank_06", coverImageName: "rank_06", caption: "Likes likes", baseLikeCount: 876),
        Seed(challengeId: "rank_07", coverImageName: "rank_07", caption: "2h makeup, 5min photos.", baseLikeCount: 1542),
        Seed(challengeId: "rank_08", coverImageName: "rank_08", caption: "It took a long time", baseLikeCount: 1198),
    ]

    private init() {}

    func items(for ownerUserId: String) -> [EP_ChallengeItem] {
        let likedIds = Set(likedChallengeIds(for: ownerUserId))
        return Self.seeds.map { seed in
            let isLiked = likedIds.contains(seed.challengeId)
            return EP_ChallengeItem(
                challengeId: seed.challengeId,
                coverImageName: seed.coverImageName,
                caption: seed.caption,
                baseLikeCount: seed.baseLikeCount,
                isLiked: isLiked
            )
        }
    }

    @discardableResult
    func toggleLike(ownerUserId: String, challengeId: String) -> [EP_ChallengeItem] {
        guard !ownerUserId.isEmpty else { return items(for: "") }
        var liked = likedChallengeIds(for: ownerUserId)
        if let index = liked.firstIndex(of: challengeId) {
            liked.remove(at: index)
        } else {
            liked.append(challengeId)
        }
        saveLikedChallengeIds(liked, ownerUserId: ownerUserId)
        return items(for: ownerUserId)
    }

    // MARK: - Private

    private func likedChallengeIds(for ownerUserId: String) -> [String] {
        guard !ownerUserId.isEmpty else { return [] }
        let key = Self.likedKey(ownerUserId: ownerUserId)
        return UserDefaults.standard.stringArray(forKey: key) ?? []
    }

    private func saveLikedChallengeIds(_ ids: [String], ownerUserId: String) {
        UserDefaults.standard.set(ids, forKey: Self.likedKey(ownerUserId: ownerUserId))
    }

    private static func likedKey(ownerUserId: String) -> String {
        "ep_challenge_liked_\(ownerUserId)"
    }
}
