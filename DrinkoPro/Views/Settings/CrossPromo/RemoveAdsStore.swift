//
//  RemoveAdsStore.swift
//  DrinkoPro
//

import StoreKit

/// Tracks the "Remove Ads" entitlement and drives restoring it. `ProductView` handles the
/// purchase itself.
@MainActor
@Observable
final class RemoveAdsStore {
    static let removeAdsProductID = "me.cilia.filippo.DrinkoPro.removeAds"

    private(set) var isAdsRemoved = false
    var restoreError: String?

    private var transactionListenerTask: Task<Void, Never>?

    enum StoreError: Error {
        case failedVerification
    }

    init() {
        // Held for the app's lifetime so Ask to Buy approvals and purchases on other devices are
        // picked up when no paywall is on screen.
        transactionListenerTask = Task { [weak self] in
            await self?.listenForTransactionUpdates()
        }

        Task { [weak self] in
            await self?.updatePurchasedStatus()
        }
    }

    func restore() async {
        restoreError = nil
        do {
            try await AppStore.sync()
        } catch {
            restoreError = error.localizedDescription
        }
        await updatePurchasedStatus()
    }

    private func listenForTransactionUpdates() async {
        for await update in Transaction.updates {
            guard let transaction = try? checkVerified(update) else { continue }

            if transaction.productID == Self.removeAdsProductID {
                isAdsRemoved = true
            }

            await transaction.finish()
        }
    }

    private func updatePurchasedStatus() async {
        for await entitlement in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(entitlement) else { continue }

            if transaction.productID == Self.removeAdsProductID {
                isAdsRemoved = true
                return
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}
