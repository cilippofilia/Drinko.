//
//  CocktailUnitPreference.swift
//  DrinkoPro
//

import SwiftUI

/// The unit cocktail recipes are shown in. Chosen in Settings; `automatic` follows the
/// measurement system of the user's region.
enum CocktailUnitPreference: String, CaseIterable, Identifiable {
    case automatic
    case milliliters
    case ounces

    /// The `@AppStorage` key the preference is saved under.
    static let storageKey = "cocktailUnitPreference"

    var id: Self { self }

    var title: LocalizedStringKey {
        switch self {
        case .automatic:
            "Automatic"
        case .milliliters:
            "Milliliters"
        case .ounces:
            "Ounces"
        }
    }

    /// The recipe unit label (`"ml"` or `"oz."`) to show for `locale`. Only the US measurement
    /// system pours in ounces; everywhere else, including the UK, uses milliliters.
    func unit(for locale: Locale) -> String {
        switch self {
        case .automatic:
            locale.measurementSystem == .us ? "oz." : "ml"
        case .milliliters:
            "ml"
        case .ounces:
            "oz."
        }
    }
}
