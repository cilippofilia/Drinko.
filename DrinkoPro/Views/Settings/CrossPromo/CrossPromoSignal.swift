//
//  CrossPromoSignal.swift
//  DrinkoPro
//

import Foundation

/// Bumped on notable user actions (favoriting a cocktail or product, creating a user cocktail,
/// or adding a cabinet category) so `HomeView` can show a cross-promo interstitial every
/// `interstitialInterval` bumps, and ask for a rating on bump `reviewRequestCount`.
@MainActor
@Observable
final class CrossPromoSignal {
    static let interstitialInterval = 5
    /// Before the first interstitial, so the rating ask follows a success moment rather than an ad.
    static let reviewRequestCount = 3

    private(set) var count = 0

    /// Whether the bump that produced `count` should show an interstitial.
    static func shouldShowInterstitial(at count: Int) -> Bool {
        count > 0 && count.isMultiple(of: interstitialInterval)
    }

    /// Once per launch; StoreKit further limits how often the prompt actually appears.
    static func shouldRequestReview(at count: Int) -> Bool {
        count == reviewRequestCount
    }

    func bump() {
        count += 1
    }
}
