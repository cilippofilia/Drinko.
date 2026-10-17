//
//  AppGroup.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 10/06/2026.
//

import Foundation

// Lets DrinkoWidget read data the app writes, such as favorites.
enum AppGroup {
    static let identifier = "group.me.cilia.filippo.DrinkoPro"

    // Holds the favorite cocktail IDs.
    static let favoritesKey = "Cocktails"

    static let widgetKind = "DrinkoWidget"

    // `.standard` on macOS, which has no widget to share with. Non-isolated so it can be a
    // default argument value; UserDefaults is thread-safe.
    nonisolated static var defaults: UserDefaults {
        #if os(iOS)
        UserDefaults(suiteName: identifier) ?? .standard
        #else
        .standard
        #endif
    }
}
