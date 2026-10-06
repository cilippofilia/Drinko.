//
//  LibraryLayout.swift
//  DrinkoPro
//

import Foundation

/// How library sections present their items. Each library screen remembers its own.
enum LibraryLayout: String, CaseIterable {
    case list
    case grid

    /// The `@AppStorage` key for the Learn library's layout.
    static let learnStorageKey = "learnLibraryLayout"

    /// The `@AppStorage` key for the Cocktails library's layout.
    static let cocktailsStorageKey = "cocktailsLibraryLayout"

    /// The `@AppStorage` key for the Tools library's layout.
    static let toolsStorageKey = "toolsLibraryLayout"

    /// The key Learn and Cocktails shared before each got its own layout.
    static let legacyStorageKey = "libraryLayout"

    /// The layout a library starts in until it's switched: whatever the old shared toggle
    /// was last set to, so nobody's layout changes on update, or `.list` if it never was.
    static func initial(in defaults: UserDefaults = .standard) -> LibraryLayout {
        defaults.string(forKey: legacyStorageKey).flatMap(LibraryLayout.init) ?? .list
    }

    /// The other layout.
    var toggled: LibraryLayout {
        self == .list ? .grid : .list
    }
}
