//
//  BundledCocktailCatalog.swift
//  DrinkoPro
//

import Foundation

/// The cocktails, shots, histories and procedures that ship inside the app, looked up by ID.
/// The App Clip shows shared cocktails from this, so it works offline.
struct BundledCocktailCatalog {
    private let cocktailsByID: [String: Cocktail]
    private let historiesByID: [String: History]
    private let proceduresByID: [String: Procedure]

    init(cocktails: [Cocktail], histories: [History], procedures: [Procedure]) {
        cocktailsByID = Dictionary(cocktails.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        historiesByID = Dictionary(histories.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        proceduresByID = Dictionary(procedures.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
    }

    /// Decodes the bundled JSON files. Cocktails and shots share one ID space.
    static func load(from bundle: Bundle = .main) -> BundledCocktailCatalog {
        BundledCocktailCatalog(
            cocktails: bundle.decode([Cocktail].self, from: "cocktails.json")
                + bundle.decode([Cocktail].self, from: "shots.json"),
            histories: bundle.decode([History].self, from: "history.json"),
            procedures: bundle.decode([Procedure].self, from: "procedure.json")
        )
    }

    func cocktail(withID id: String) -> Cocktail? {
        cocktailsByID[id]
    }

    func history(for cocktail: Cocktail) -> History? {
        historiesByID[cocktail.id]
    }

    func procedure(for cocktail: Cocktail) -> Procedure? {
        proceduresByID[cocktail.id]
    }
}
