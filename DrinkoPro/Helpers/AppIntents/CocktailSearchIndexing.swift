import AppIntents
import CoreSpotlight

/// The slice of Spotlight indexing the app uses, so tests can substitute a fake.
@MainActor
protocol CocktailSearchIndexing {
    func indexCocktails(_ entities: [CocktailEntity]) async throws
    func deleteAllCocktails() async throws
}

extension CSSearchableIndex: CocktailSearchIndexing {
    func indexCocktails(_ entities: [CocktailEntity]) async throws {
        try await indexAppEntities(entities)
    }

    func deleteAllCocktails() async throws {
        try await deleteAppEntities(ofType: CocktailEntity.self)
    }
}
