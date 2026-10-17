//
//  WidgetDrinkSource.swift
//  DrinkoWidget
//
//  Created by Filippo Cilia on 10/06/2026.
//

import Foundation

// Free of AppIntents so the pool and pick logic can be unit tested from the app target.
enum WidgetDrinkSource: String, CaseIterable, Sendable {
    case allDrinks
    case cocktailsOnly
    case shotsOnly
    case favoritesOnly
}

extension DrinkoWidgetCatalog {
    // "Favorites Only" with no matching favorites falls back to every cocktail and shot,
    // so the widget never renders blank.
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

    // Indexes by the day's ordinal in the era, so a given day always yields the same drink
    // and consecutive days step through the pool.
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
