//
//  AppGroup.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 10/06/2026.
//

import Foundation

// Shared identifiers for the App Group that lets DrinkoWidget read data
// (such as favorites) written by the main app.
enum AppGroup {
    // The App Group identifier registered for both the app and widget targets.
    static let identifier = "group.me.cilia.filippo.DrinkoPro"

    // The UserDefaults key used to store favorite cocktail IDs.
    static let favoritesKey = "Cocktails"

    // The widget kind used when requesting timeline reloads.
    static let widgetKind = "DrinkoWidget"

    // The shared UserDefaults suite. On iOS this is the App Group container so the
    // widget extension can read favorites; on macOS there is no widget extension to
    // share with, so we fall back to `.standard`. UserDefaults access is thread-safe,
    // so this is explicitly non-isolated for use as a default argument value.
    nonisolated static var defaults: UserDefaults {
        #if os(iOS)
        UserDefaults(suiteName: identifier) ?? .standard
        #else
        .standard
        #endif
    }
}
