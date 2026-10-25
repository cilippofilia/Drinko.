//
//  ClipCocktail.swift
//  DrinkoClip
//

import Foundation

/// A cocktail together with the history and procedure that go with it.
struct ClipCocktail: Equatable, Sendable {
    let cocktail: Cocktail
    let history: History?
    let procedure: Procedure?

    /// Nil when the catalog doesn't contain `id`.
    init?(id: String, in catalog: BundledCocktailCatalog) {
        guard let cocktail = catalog.cocktail(withID: id) else { return nil }
        self.cocktail = cocktail
        history = catalog.history(for: cocktail)
        procedure = catalog.procedure(for: cocktail)
    }
}
