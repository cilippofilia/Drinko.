//
//  CrossPromoSignal.swift
//  DrinkoPro
//

import Foundation

/// Bumped on notable user actions (favoriting a cocktail or product, creating a user cocktail,
/// or adding a cabinet category) so `HomeView` can show a PrivateAds cross-promo interstitial
/// every `interstitialInterval` bumps, regardless of which tab the action happened in.
@MainActor
@Observable
final class CrossPromoSignal {
    /// How many bumps between interstitials.
    static let interstitialInterval = 5

    private(set) var count = 0

    /// Whether the bump that produced `count` should show an interstitial.
    static func shouldShowInterstitial(at count: Int) -> Bool {
        count > 0 && count.isMultiple(of: interstitialInterval)
    }

    func bump() {
        count += 1
    }
}
