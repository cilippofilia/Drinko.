//
//  AdConfiguration+CrossPromo.swift
//  DrinkoPro
//

import PrivateAds
import Foundation

extension AdConfiguration {
    /// Uses a personal feed (github.com/cilippofilia/cross-promo-ads) instead of PrivateAds's shared
    /// one, so only Filippo Cilia's own apps show up. "6449893371" is Drinko's Apple ID, excluded
    /// so it's never advertised to its own users.
    static let crossPromo = AdConfiguration(
        adsJSONURL: URL(string: "https://raw.githubusercontent.com/cilippofilia/cross-promo-ads/main/ads.json"),
        excludedIDs: ["6449893371"]
    )
}
