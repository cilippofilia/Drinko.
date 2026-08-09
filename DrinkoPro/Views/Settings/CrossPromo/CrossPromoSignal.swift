//
//  CrossPromoSignal.swift
//  DrinkoPro
//

import Foundation

/// Bumped on notable user actions (favoriting a cocktail or product, creating a user cocktail,
/// or adding a cabinet category) so `HomeView` can show a PrivateAds cross-promo interstitial
/// every 3rd bump, regardless of which tab the action happened in.
@MainActor
@Observable
final class CrossPromoSignal {
    private(set) var count = 0

    func bump() {
        count += 1
    }
}
