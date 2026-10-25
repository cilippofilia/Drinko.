import AppIntents
import Foundation

/// Looks cocktails up by id, spoken name, or the full library for Siri's phrase registration.
struct CocktailEntityQuery: EntityStringQuery {
    @Dependency var cocktails: CocktailsViewModel

    func entities(for identifiers: [String]) async throws -> [CocktailEntity] {
        let library = await allDrinks()
        let byID = Dictionary(library.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        return identifiers.compactMap { byID[$0] }.map(CocktailEntity.init)
    }

    func entities(matching string: String) async throws -> [CocktailEntity] {
        Self.results(matching: string, in: await allDrinks())
    }

    /// Every drink, which registers the names for Siri phrases.
    func suggestedEntities() async throws -> [CocktailEntity] {
        await allDrinks().map(CocktailEntity.init)
    }

    /// Exact and partial matches, or every closest one when nothing matches, so Siri asks which.
    static func results(matching string: String, in library: [Cocktail]) -> [CocktailEntity] {
        let found = CocktailNameMatcher.matches(string, in: library)
        if !found.isEmpty { return found.map(CocktailEntity.init) }
        return CocktailNameMatcher.closestMatches(to: string, in: library).map(CocktailEntity.init)
    }

    @MainActor
    private func allDrinks() -> [Cocktail] {
        cocktails.listOfAllDrinks
    }
}
