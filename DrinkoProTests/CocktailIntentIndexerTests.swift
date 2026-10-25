import Testing
@testable import DrinkoPro

@MainActor
private final class FakeSearchIndex: CocktailSearchIndexing {
    private(set) var indexedBatches: [[CocktailEntity]] = []
    private(set) var deleteCount = 0

    func indexCocktails(_ entities: [CocktailEntity]) async throws {
        indexedBatches.append(entities)
    }

    func deleteAllCocktails() async throws {
        deleteCount += 1
    }
}

@MainActor
struct CocktailIntentIndexerTests {
    private func drinks(_ names: [String]) -> [Cocktail] {
        names.enumerated().map { index, name in
            Cocktail(
                id: "drink-\(index)", name: name, method: "stir", glass: "-",
                garnish: "-", ice: "-", extra: "-", ingredients: []
            )
        }
    }

    @Test func updateIndexesEveryDrink() async {
        let index = FakeSearchIndex()
        var parameterUpdates = 0
        let indexer = CocktailIntentIndexer(index: index) { parameterUpdates += 1 }

        await indexer.update(with: drinks(["Zombie", "Negroni", "Daiquiri"]))

        #expect(index.indexedBatches.count == 1)
        #expect(index.indexedBatches.first?.count == 3)
        #expect(parameterUpdates == 1)
    }

    @Test func unchangedListIsSkipped() async {
        let index = FakeSearchIndex()
        var parameterUpdates = 0
        let indexer = CocktailIntentIndexer(index: index) { parameterUpdates += 1 }
        let list = drinks(["Zombie", "Negroni"])

        await indexer.update(with: list)
        await indexer.update(with: list)

        #expect(index.indexedBatches.count == 1)
        #expect(parameterUpdates == 1)
    }

    @Test func renamedUserCocktailReindexes() async {
        let index = FakeSearchIndex()
        let indexer = CocktailIntentIndexer(index: index) {}

        await indexer.update(with: drinks(["Zombie", "My Drink"]))
        await indexer.update(with: drinks(["Zombie", "My Better Drink"]))

        #expect(index.indexedBatches.count == 2)
    }
}
