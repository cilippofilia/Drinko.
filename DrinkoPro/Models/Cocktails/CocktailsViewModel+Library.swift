//
//  CocktailsViewModel+Library.swift
//  DrinkoPro
//

import Foundation
import SwiftUI

extension CocktailsViewModel {
    /// The current cocktail list as library sections, using the active sort, search, filter and source.
    func librarySections(
        filterOption: FilterOption,
        source: CocktailListSource = .userAndApp,
        isFavorite: (Cocktail) -> Bool
    ) -> [LibrarySection<Cocktail>] {
        let grouped = groupedCocktails(filterOption: filterOption, source: source, isFavorite: isFavorite)
        let keys = sortedSectionKeys(filterOption: filterOption, source: source, isFavorite: isFavorite)
        return keys.map { key in
            LibrarySection(id: key, title: key, items: grouped[key] ?? [])
        }
    }

    /// Display data for a cocktail: title only, photo for app cocktails, glass artwork for the user's own.
    func cardModel(for cocktail: Cocktail) -> LibraryCardModel {
        LibraryCardModel(title: cocktail.name, image: libraryImage(for: cocktail), imageContentMode: .fit)
    }

    /// Maps stored recent IDs back to cocktails, keeping order and dropping deleted ones.
    func recentItems(from ids: [String]) -> [Cocktail] {
        let drinksByID = Dictionary(listOfAllDrinks.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        return ids.compactMap { drinksByID[$0] }
    }

    private func libraryImage(for cocktail: Cocktail) -> LibraryImage {
        guard cocktail.id.hasPrefix("user-") else {
            return .remote(URL(string: cocktail.pic))
        }

        switch cocktail.glass {
        case "wine":
            return .symbol("wineglass")
        case "coffee mug", "julep cup":
            return .asset("julep")
        default:
            return .asset(cocktail.image)
        }
    }
}
