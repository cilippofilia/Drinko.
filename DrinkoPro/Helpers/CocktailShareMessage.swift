//
//  CocktailShareMessage.swift
//  DrinkoPro
//

import Foundation

/// The text sent alongside a cocktail's recipe card. Built-in cocktails, including ones that arrive
/// through downloaded content, get the App Clip link, because the App Clip fetches cocktails it
/// doesn't bundle. The user's own cocktails don't: the App Clip can't see their private recipes.
///
/// There are several wordings so repeated shares don't all read the same. The caller picks one with
/// `randomVariant()` and keeps it, so the text doesn't change while the share sheet is open.
enum CocktailShareMessage {
    /// How many wordings there are.
    static var variantCount: Int { templates(name: "", link: "").count }

    /// A random wording index, valid for `text(for:variant:)`.
    static func randomVariant() -> Int {
        Int.random(in: 0..<variantCount)
    }

    /// The share text using wording `variant`, which wraps around if it's out of range.
    static func text(for cocktail: Cocktail, variant: Int) -> String? {
        guard !cocktail.isUserCreated else { return nil }
        let link = CocktailClipLink.url(for: cocktail.id).absoluteString
        let templates = templates(name: cocktail.name, link: link)
        let index = ((variant % templates.count) + templates.count) % templates.count
        return templates[index]
    }

    /// Every wording, in a fixed order. Each has the cocktail name followed by the link.
    static func templates(name: String, link: String) -> [String] {
        [
            String(
                localized: "Tonight's pour: \(name) 🍸\nHere's how to make it:\n\(link)",
                comment: "Cocktail share text. Values: cocktail name, then a Drinko App Clip recipe link."
            ),
            String(
                localized: "Shaking things up: \(name) 🍹\nGrab the recipe:\n\(link)",
                comment: "Cocktail share text. Values: cocktail name, then a Drinko App Clip recipe link."
            ),
            String(
                localized: "You need to try this one: \(name) 🥂\nHere's the recipe:\n\(link)",
                comment: "Cocktail share text. Values: cocktail name, then a Drinko App Clip recipe link."
            ),
            String(
                localized: "My next round: \(name) 🍸\nMake one with me:\n\(link)",
                comment: "Cocktail share text. Values: cocktail name, then a Drinko App Clip recipe link."
            ),
            String(
                localized: "Cheers! In my glass: \(name) 🥃\nSee how it's made:\n\(link)",
                comment: "Cocktail share text. Values: cocktail name, then a Drinko App Clip recipe link."
            ),
            String(
                localized: "New favourite unlocked: \(name) 🍋\nThe recipe's all here:\n\(link)",
                comment: "Cocktail share text. Values: cocktail name, then a Drinko App Clip recipe link."
            ),
            String(
                localized: "Happy hour pick: \(name) 🍸\nTry it yourself:\n\(link)",
                comment: "Cocktail share text. Values: cocktail name, then a Drinko App Clip recipe link."
            ),
            String(
                localized: "On the bar tonight: \(name) 🧊\nWant the recipe?\n\(link)",
                comment: "Cocktail share text. Values: cocktail name, then a Drinko App Clip recipe link."
            )
        ]
    }
}
