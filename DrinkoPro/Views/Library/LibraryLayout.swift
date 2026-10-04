//
//  LibraryLayout.swift
//  DrinkoPro
//

import Foundation

/// How library sections present their items. Shared by every library screen.
enum LibraryLayout: String, CaseIterable {
    case list
    case grid

    /// The `@AppStorage` key shared by Learn and Cocktails.
    static let storageKey = "libraryLayout"

    /// The other layout.
    var toggled: LibraryLayout {
        self == .list ? .grid : .list
    }
}
