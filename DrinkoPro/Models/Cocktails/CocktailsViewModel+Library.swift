//
//  CocktailsViewModel+Library.swift
//  DrinkoPro
//

import Foundation
import SwiftUI

extension CocktailsViewModel {
    /// The current cocktail list as library sections, using the active sort, search, filter and source.
    ///
    /// Groups the cocktails once, then only sorts the resulting keys, instead of grouping twice
    /// (once directly, once again inside `sortedSectionKeys`).
    func librarySections(
        filterOption: FilterOption,
        source: CocktailListSource = .userAndApp,
        isFavorite: (Cocktail) -> Bool
    ) -> [LibrarySection<Cocktail>] {
        let grouped = groupedCocktails(filterOption: filterOption, source: source, isFavorite: isFavorite)
        let keys = sortSectionKeys(Array(grouped.keys))
        return keys.map { key in
            LibrarySection(id: key, title: key, items: grouped[key] ?? [])
        }
    }

    /// Display data for a cocktail: title only, a sticker for app cocktails (or a photo for the
    /// few without one), glass artwork for the user's own, and a heart when it's a favorite.
    func cardModel(for cocktail: Cocktail, isFavorite: Bool = false) -> LibraryCardModel {
        LibraryCardModel(title: cocktail.name, image: libraryImage(for: cocktail), imageContentMode: .fit, isFavorite: isFavorite)
    }

    /// Maps stored recent IDs back to cocktails, keeping order and dropping deleted ones.
    ///
    /// Looks up bundled drinks in the cached id → cocktail dictionary first (bundled cocktails
    /// never change, so that dictionary is built once), then falls back to `userCocktails`, which
    /// can change as the user edits or deletes their own cocktails.
    func recentItems(from ids: [String]) -> [Cocktail] {
        let bundledDrinksByID = bundledDrinksByID
        return ids.compactMap { id in
            bundledDrinksByID[id] ?? userCocktails.first { $0.id == id }
        }
    }

    /// The recent cocktails for the "Last Viewed" carousel, which is all pictures, so it skips
    /// cocktails without one.
    func recentCocktailsWithPictures(from ids: [String]) -> [Cocktail] {
        recentItems(from: ids).filter { hasPicture($0) }
    }

    /// Sorts already-grouped keys by `sortOption`, keeping "#" last for A→Z/Z→A. Shared by
    /// `sortedSectionKeys` and `librarySections` so grouping only happens once per call.
    func sortSectionKeys(_ keys: [String]) -> [String] {
        let sortedKeys: [String]
        switch sortOption {
        case .fromZtoA:
            sortedKeys = keys.sorted(by: >)
        default:
            sortedKeys = keys.sorted(by: <)
        }

        // Names starting with a number or symbol share the "#" section, which goes at the bottom.
        let lastKey = Self.nonLetterSectionKey
        guard sortOption == .fromAtoZ || sortOption == .fromZtoA, sortedKeys.contains(lastKey) else {
            return sortedKeys
        }
        return sortedKeys.filter { $0 != lastKey } + [lastKey]
    }

    /// The bundled (non-user) drinks keyed by id, built once on first use since they never
    /// change after launch.
    private var bundledDrinksByID: [String: Cocktail] {
        if let cached = bundledDrinksByIDCache {
            return cached
        }
        let dict = Dictionary(
            (listOfCocktails + listOfShots).map { ($0.id, $0) },
            uniquingKeysWith: { first, _ in first }
        )
        bundledDrinksByIDCache = dict
        return dict
    }

    /// The card tint for `cocktail`: its main spirit's color, or for the user's own cocktails
    /// without one, the color they picked. The spirit lookup is cached per id since bundled
    /// cocktails never change and it folds over ~40 ingredient-name fragments.
    func stickerTint(for cocktail: Cocktail) -> String? {
        let spirit: MainSpirit?
        if let cached = stickerTintCache[cocktail.id] {
            spirit = cached
        } else {
            spirit = MainSpirit(ingredients: cocktail.ingredients)
            stickerTintCache[cocktail.id] = spirit
        }
        if let spirit {
            return spirit.colorName
        }
        return cocktail.isUserCreated ? userTintColors[cocktail.id] : nil
    }

    /// The card color the user picked for this cocktail, whether or not a main spirit is
    /// currently overriding it. `nil` when they haven't picked one.
    func pickedTintColor(for cocktail: Cocktail) -> String? {
        userTintColors[cocktail.id]
    }

    private func libraryImage(for cocktail: Cocktail) -> LibraryImage {
        guard cocktail.isUserCreated else {
            if let stickerURL = cocktail.stickerURL {
                return .sticker(stickerURL, tint: stickerTint(for: cocktail))
            }
            return .remote(URL(string: cocktail.pic))
        }

        if hasSticker(cocktail) {
            return .userSticker(
                id: cocktail.id,
                revision: photoRevision(for: cocktail.id),
                tint: stickerTint(for: cocktail)
            )
        }
        if hasPhoto(cocktail) {
            return .userPhoto(id: cocktail.id, revision: photoRevision(for: cocktail.id))
        }
        return .glass(cocktail.glassArtwork, tint: stickerTint(for: cocktail))
    }
}
