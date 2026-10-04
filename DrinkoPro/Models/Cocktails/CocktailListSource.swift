//
//  CocktailListSource.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 04/10/2026.
//

import SwiftUI

/// Which cocktails the Cocktails list draws from. Chosen in Settings and
/// applied before the list's own filter menu.
enum CocktailListSource: String, CaseIterable, Identifiable {
    case userAndApp
    case appOnly
    case userOnly

    /// The `@AppStorage` key the preference is saved under.
    static let storageKey = "cocktailListSource"

    var id: Self { self }

    var title: LocalizedStringKey {
        switch self {
        case .userAndApp:
            "All"
        case .appOnly:
            "Drinko Only"
        case .userOnly:
            "User Created Only"
        }
    }

    var includesAppCocktails: Bool {
        self != .userOnly
    }

    var includesUserCocktails: Bool {
        self != .appOnly
    }
}
