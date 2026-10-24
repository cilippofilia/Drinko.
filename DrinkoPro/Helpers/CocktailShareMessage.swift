//
//  CocktailShareMessage.swift
//  DrinkoPro
//

import Foundation

/// The text sent alongside a cocktail's recipe card. Cocktails that ship in the app get the App
/// Clip link, so receivers can open the full recipe. The user's own cocktails don't: the App Clip
/// can't see their private recipes. Neither do cocktails that only exist in downloaded content:
/// the App Clip resolves ids from the bundled catalog alone.
enum CocktailShareMessage {
    /// Loaded once, because the catalog decodes several JSON files.
    private static let bundledCatalog = BundledCocktailCatalog.load()

    static func text(for cocktail: Cocktail, catalog: BundledCocktailCatalog = bundledCatalog) -> String? {
        guard !cocktail.isUserCreated, catalog.cocktail(withID: cocktail.id) != nil else { return nil }
        let link = CocktailClipLink.url(for: cocktail.id).absoluteString
        return String(localized: """
            Tonight's pour: \(cocktail.name) 🍸
            Here's how to make it:
            \(link)
            """, comment: "Share text for a built-in cocktail. The link opens the recipe in the Drinko App Clip.")
    }
}
