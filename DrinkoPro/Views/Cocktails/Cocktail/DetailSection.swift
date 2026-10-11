//
//  DetailSection.swift
//  DrinkoPro
//

import Foundation

/// The collapsible cards on the cocktail detail screen. Their raw values are what
/// `CollapsedSections` stores, so collapsing a card applies to every cocktail.
enum DetailSection: String, CaseIterable {
    case ingredients
    case procedure
    case suggested

    /// The `@AppStorage` key the collapsed cards are saved under.
    static let storageKey = "detailCollapsedSections"
}
