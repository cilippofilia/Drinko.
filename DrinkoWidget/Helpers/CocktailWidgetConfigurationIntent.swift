//
//  CocktailWidgetConfigurationIntent.swift
//  DrinkoWidget
//
//  Created by Filippo Cilia on 10/06/2026.
//

import AppIntents
import WidgetKit

// The content source a user can pick when configuring the widget via
// "Edit Widget". Maps 1:1 to `WidgetDrinkSource`, which carries the actual
// pool/pick logic so it can be unit tested without AppIntents.
enum DrinkSource: String, AppEnum {
    case allDrinks
    case cocktailsOnly
    case shotsOnly
    case favoritesOnly

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Drink Source"

    static let caseDisplayRepresentations: [DrinkSource: DisplayRepresentation] = [
        .allDrinks: "All Drinks",
        .cocktailsOnly: "Cocktails Only",
        .shotsOnly: "Shots Only",
        .favoritesOnly: "Favorites Only"
    ]

    var widgetDrinkSource: WidgetDrinkSource {
        switch self {
        case .allDrinks: .allDrinks
        case .cocktailsOnly: .cocktailsOnly
        case .shotsOnly: .shotsOnly
        case .favoritesOnly: .favoritesOnly
        }
    }
}

// User-configurable settings for "Cocktail of the Day", surfaced through the
// widget gallery's "Edit Widget" sheet.
struct CocktailWidgetConfigurationIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Cocktail of the Day"
    static let description = IntentDescription("Choose what kind of drink to feature and whether to show its ingredients.")

    @Parameter(title: "Show", default: .allDrinks)
    var source: DrinkSource

    @Parameter(title: "Show Ingredients", default: true)
    var showsIngredients: Bool
}
