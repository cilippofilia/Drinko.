//
//  LibrarySection.swift
//  DrinkoPro
//

import Foundation

struct LibrarySection<Item: Identifiable & Hashable>: Identifiable, Hashable {
    /// Persists the collapsed state, so keep it stable.
    let id: String
    var title: String
    var items: [Item]
}
