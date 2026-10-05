//
//  MainSpirit.swift
//  DrinkoPro
//

import Foundation

/// The ingredient family a cocktail is built on, matching the Cabinet's suggested categories so a
/// drink can share its category's color.
enum MainSpirit: CaseIterable {
    case vodka
    case gin
    case whiskey
    case rum
    case tequila
    case cognac
    case liqueur
    case juice
    case syrup

    /// The color asset the Cabinet's matching suggested category uses.
    var colorName: String {
        switch self {
        case .vodka: "Dr. Magenta"
        case .gin: "Dr. Lavender"
        case .whiskey: "Dr. Gold"
        case .rum: "Dr. Poppy"
        case .tequila: "Dr. Green"
        case .cognac: "Dr. Orange"
        case .liqueur: "Dr. Sky"
        case .juice: "Dr. Bubblegum"
        case .syrup: "Dr. Red"
        }
    }

    /// Spirits beat liqueurs, which beat juices, which beat syrups.
    private var rank: Int {
        switch self {
        case .vodka, .gin, .whiskey, .rum, .tequila, .cognac: 0
        case .liqueur: 1
        case .juice: 2
        case .syrup: 3
        }
    }

    /// The main spirit of a drink: the best-ranked family among its ingredients, and within that
    /// rank the one poured in the largest amount (the first listed on a tie). `nil` when no
    /// ingredient belongs to a family, such as a wine-based drink.
    @MainActor
    init?(ingredients: [Ingredient]) {
        var best: (spirit: MainSpirit, amount: Double)?

        for ingredient in ingredients {
            guard let spirit = MainSpirit(ingredientName: ingredient.name) else { continue }
            let amount = ingredient.mlQuantity

            if let current = best {
                let outranks = spirit.rank < current.spirit.rank
                let pouredMore = spirit.rank == current.spirit.rank && amount > current.amount
                guard outranks || pouredMore else { continue }
            }
            best = (spirit, amount)
        }

        guard let best else { return nil }
        self = best.spirit
    }

    /// Recognizes an ingredient from its name in any of the app's languages.
    init?(ingredientName: String) {
        let name = ingredientName.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
        let words = name.split { !$0.isLetter }.map(String.init)

        func mentions(_ fragments: [String]) -> Bool {
            fragments.contains { name.contains($0) }
        }

        // Liqueurs first, so "Pear & Cognac Liqueur" or "Coconut Rum Liqueur" count as liqueurs.
        if mentions(Self.liqueurFragments) {
            self = .liqueur
        } else if mentions(["tequila", "mezcal"]) {
            self = .tequila
        } else if mentions(["whisk", "bourbon", "scotch"]) {
            self = .whiskey
        } else if mentions(["vodka", "wodka"]) {
            self = .vodka
        } else if words.contains("gin") {
            self = .gin
        } else if mentions(["rum", "rhum", "cachaca"]) || words.contains("ron") {
            self = .rum
        } else if mentions(["cognac", "conac", "brandy", "calvados", "armagnac", "pisco"]) {
            self = .cognac
        } else if mentions(["juice", "succo", "zumo", "saft"]) || words.contains("jus") {
            self = .juice
        } else if mentions(["syrup", "sciroppo", "sirope", "sirop", "sirup", "grenadine", "granadin", "orgeat"]) {
            self = .syrup
        } else {
            return nil
        }
    }

    /// Generic words for liqueur, plus liqueurs usually listed by brand.
    private static let liqueurFragments = [
        "liqueur", "liquore", "licor", "likor", "schnapps", "schnaps", "creme de", "crema de",
        "absinth", "absenta", "assenzio", "amaretto", "amaro", "aperol", "bailey", "benedictine",
        "campari", "chartreuse", "cointreau", "couintreau", "curacao", "cynar", "disaronno",
        "drambuie", "fernet", "galliano", "grand marnier", "heering", "jagermeister", "kahlua",
        "maraschino", "sambuca", "triple sec"
    ]
}
