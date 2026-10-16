//
//  CocktailShareMessage.swift
//  DrinkoPro
//

import Foundation

/// The text sent alongside a cocktail's recipe card. Built-in cocktails get the App Clip link,
/// so receivers can open the full recipe. The user's own cocktails don't: the App Clip can't
/// see their private recipes.
enum CocktailShareMessage {
    static func text(for cocktail: Cocktail) -> String? {
        guard !cocktail.isUserCreated else { return nil }
        let link = CocktailClipLink.url(for: cocktail.id).absoluteString
        return String(localized: "\(cocktail.name) on Drinko: \(link)")
    }
}
