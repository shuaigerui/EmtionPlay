//
//  EP_IAPManager.swift
//  EmtionPlayRp
//

import Foundation
import StoreKit

/// App Store 内购（StoreKit 2）
@MainActor
final class EP_IAPManager {

    static let shared = EP_IAPManager()

    struct CatalogItem {
        let productId: String
        let coinAmount: Int
        let fallbackPriceText: String
    }

    /// 金额、钻石数、苹果商品 id（与 App Store Connect 一致）
    static let catalog: [CatalogItem] = [
        CatalogItem(productId: "slhpvfyqhldwdyuw", coinAmount: 400, fallbackPriceText: "$0.99"),
        CatalogItem(productId: "afokknudeqiofeuz", coinAmount: 800, fallbackPriceText: "$1.99"),
        CatalogItem(productId: "ssjeyeudteemclbj", coinAmount: 2450, fallbackPriceText: "$4.99"),
        CatalogItem(productId: "khnylxhdbrnxlnpa", coinAmount: 5150, fallbackPriceText: "$9.99"),
        CatalogItem(productId: "pkdxjrwkmgruiaat", coinAmount: 10800, fallbackPriceText: "$19.99"),
        CatalogItem(productId: "eouqaamferzbudxb", coinAmount: 29400, fallbackPriceText: "$49.99"),
        CatalogItem(productId: "wwhpiqcxfyrywcm0", coinAmount: 63700, fallbackPriceText: "$99.99"),
    ]

    enum PurchaseError: LocalizedError {
        case productNotFound
        case failedVerification
        case notLoggedIn
        case persistFailed

        var errorDescription: String? {
            switch self {
            case .productNotFound:
                return "Product is not available. Please try again later."
            case .failedVerification:
                return "Purchase verification failed."
            case .notLoggedIn:
                return "Please sign in before purchasing."
            case .persistFailed:
                return "Failed to update your balance."
            }
        }
    }

    private var storeProducts: [String: Product] = [:]
    private var updatesTask: Task<Void, Never>?
    private var processedTransactionIds: Set<UInt64> = []

    private init() {
        processedTransactionIds = Self.loadProcessedTransactionIds()
    }

    func start() {
        guard updatesTask == nil else { return }
        updatesTask = Task { [weak self] in
            guard let self else { return }
            for await update in Transaction.updates {
                await self.handle(transactionResult: update)
            }
        }
        Task { await loadProducts() }
    }

    func shopItems() -> [EP_ShopProductItem] {
        Self.catalog.map { item in
            EP_ShopProductItem(
                productId: item.productId,
                coinAmount: item.coinAmount,
                priceText: displayPrice(for: item.productId) ?? item.fallbackPriceText
            )
        }
    }

    func displayPrice(for productId: String) -> String? {
        storeProducts[productId]?.displayPrice
    }

    func loadProducts() async {
        let ids = Set(Self.catalog.map(\.productId))
        do {
            let products = try await Product.products(for: ids)
            var map: [String: Product] = [:]
            for product in products {
                map[product.id] = product
            }
            storeProducts = map
        } catch {
            storeProducts = [:]
        }
    }

    @discardableResult
    func purchase(productId: String) async throws -> Bool {
        guard EP_CurrentUser.shared.user != nil else {
            throw PurchaseError.notLoggedIn
        }
        guard let product = storeProducts[productId] else {
            throw PurchaseError.productNotFound
        }

        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            let delivered = await deliverCoins(for: transaction)
            await transaction.finish()
            return delivered
        case .userCancelled, .pending:
            return false
        @unknown default:
            return false
        }
    }

    func coinAmount(for productId: String) -> Int? {
        Self.catalog.first { $0.productId == productId }?.coinAmount
    }

    // MARK: - Private

    private func handle(transactionResult: VerificationResult<Transaction>) async {
        do {
            let transaction = try checkVerified(transactionResult)
            _ = await deliverCoins(for: transaction)
            await transaction.finish()
        } catch {
            // ignore unverified
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PurchaseError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    @discardableResult
    private func deliverCoins(for transaction: Transaction) async -> Bool {
        guard transaction.revocationDate == nil else { return false }
        guard !processedTransactionIds.contains(transaction.id) else { return true }

        let productId = transaction.productID
        guard let coins = coinAmount(for: productId),
              let userId = EP_CurrentUser.shared.user?.userId,
              var user = UserData.shared.user(userId: userId) else {
            return false
        }

        user.coins += coins
        guard UserData.shared.updateUser(user) else {
            return false
        }
        EP_CurrentUser.shared.refreshFromDatabase()

        processedTransactionIds.insert(transaction.id)
        saveProcessedTransactionIds()
        return true
    }

    private static let processedKey = "ep_iap_processed_transaction_ids"

    private static func loadProcessedTransactionIds() -> Set<UInt64> {
        let strings = UserDefaults.standard.stringArray(forKey: processedKey) ?? []
        return Set(strings.compactMap { UInt64($0) })
    }

    private func saveProcessedTransactionIds() {
        let strings = processedTransactionIds.map { String($0) }
        UserDefaults.standard.set(strings, forKey: Self.processedKey)
    }
}
