//
//  RemoveAdsStore.swift
//  DrinkoPro
//

import StoreKit

/// Tracks entitlement for the one-time "Remove Ads" non-consumable purchase that silences the
/// Billboard cross-promo ads (see `CrossPromoBannerView`). The purchase button itself is
/// StoreKit's `ProductView` in `CrossPromoRemoveAdsInfoView` — this store only needs to know
/// whether the entitlement is held, and to drive the restore flow that `ProductView` doesn't
/// provide on its own.
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
        // Held for the app's lifetime so Ask-to-Buy approvals, restores, and purchases made on
        // another device are picked up even when no paywall is on screen.
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
