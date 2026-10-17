//
//  LibraryLayout.swift
//  DrinkoPro
//

import Foundation

enum LibraryLayout: String, CaseIterable {
    case list
    case grid

    static let learnStorageKey = "learnLibraryLayout"

    static let cocktailsStorageKey = "cocktailsLibraryLayout"

    /// The key Learn and Cocktails shared before each got its own layout.
    static let legacyStorageKey = "libraryLayout"

    /// The old shared toggle's layout, so nobody's layout changes on update, or `.list`.
    static func initial(in defaults: UserDefaults = .standard) -> LibraryLayout {
        defaults.string(forKey: legacyStorageKey).flatMap(LibraryLayout.init) ?? .list
    }

    var toggled: LibraryLayout {
        self == .list ? .grid : .list
    }
}
