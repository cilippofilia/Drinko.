//
//  WidgetDrinkSource.swift
//  DrinkoWidget
//
//  Created by Filippo Cilia on 10/06/2026.
//

import Foundation

// AppIntents-free representation of the widget's content source, so the pure
// pool/pick logic below can be unit tested from the app target without
// linking AppIntents.
enum WidgetDrinkSource: String, CaseIterable, Sendable {
    case allDrinks
    case cocktailsOnly
    case shotsOnly
    case favoritesOnly
}

extension DrinkoWidgetCatalog {
    // Builds the pool of drinks the widget can pick from for a given source.
    // "Favorites Only" with no favorites (or no matching IDs) falls back to
    // every cocktail and shot, so the widget never renders blank.
    static func pool(
        for source: WidgetDrinkSource,
        cocktails: [WidgetCocktail],
        shots: [WidgetCocktail],
        favoriteIDs: Set<String>
    ) -> [WidgetCocktail] {
        switch source {
        case .allDrinks:
            return cocktails + shots

        case .cocktailsOnly:
            return cocktails

        case .shotsOnly:
            return shots

        case .favoritesOnly:
            let favorites = (cocktails + shots).filter { favoriteIDs.contains($0.id) }
            return favorites.isEmpty ? cocktails + shots : favorites
        }
    }

    // Deterministically picks "today's" drink from a pool, using the day's
    // ordinal position in the calendar era so the same pool always yields the
    // same drink on a given day, and consecutive days advance through it.
    static func dailyPick(
        from pool: [WidgetCocktail],
        on date: Date,
        calendar: Calendar = .autoupdatingCurrent
    ) -> WidgetCocktail? {
        guard !pool.isEmpty else { return nil }

        let dayIndex = calendar.ordinality(of: .day, in: .era, for: date) ?? 0
        return pool[dayIndex % pool.count]
    }
}
