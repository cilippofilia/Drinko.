//
//  LibrarySection.swift
//  DrinkoPro
//

import Foundation

/// A titled group of items shown by `LibraryView`.
struct LibrarySection<Item: Hashable>: Identifiable, Hashable {
    /// Stable identifier, also used to persist the collapsed state.
    let id: String
    var title: String
    var items: [Item]
}
