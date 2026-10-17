//
//  DetailSection.swift
//  DrinkoPro
//

import Foundation

/// Raw values are persisted by `CollapsedSections`, so collapsing a card applies to every
/// cocktail.
enum DetailSection: String, CaseIterable {
    case ingredients
    case procedure
    case suggested

    static let storageKey = "detailCollapsedSections"
}
