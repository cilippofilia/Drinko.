import Testing
@testable import DrinkoPro

private enum FakeIndexError: Error { case failed }

@MainActor
private final class FakeSearchIndex: CocktailSearchIndexing {
    private(set) var indexedBatches: [[CocktailEntity]] = []
    private(set) var deleteCount = 0
    var suspendNextDelete = false
    var failNextIndex = false
    private(set) var release: CheckedContinuation<Void, Never>?

    func indexCocktails(_ entities: [CocktailEntity]) async throws {
        if failNextIndex {
            failNextIndex = false
            throw FakeIndexError.failed
        }
        indexedBatches.append(entities)
    }

    func deleteAllCocktails() async throws {
        deleteCount += 1
        if suspendNextDelete {
            suspendNextDelete = false
            await withCheckedContinuation { release = $0 }
        }
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

    @Test func concurrentUpdatesEndOnTheLatestList() async {
        let index = FakeSearchIndex()
        index.suspendNextDelete = true
        var parameterUpdates = 0
        let indexer = CocktailIntentIndexer(index: index) { parameterUpdates += 1 }

        let first = Task { await indexer.update(with: drinks(["Zombie"])) }
        while index.release == nil { await Task.yield() }
        await indexer.update(with: drinks(["Zombie", "Negroni"]))
        index.release?.resume()
        await first.value

        #expect(index.indexedBatches.last?.count == 2)
        #expect(index.indexedBatches.count == 2)
        #expect(parameterUpdates == 2)
    }

    @Test func failedIndexIsRetriedWithTheSameList() async {
        let index = FakeSearchIndex()
        var parameterUpdates = 0
        let indexer = CocktailIntentIndexer(index: index) { parameterUpdates += 1 }
        let list = drinks(["Zombie"])

        await indexer.update(with: list)
        index.failNextIndex = true
        await indexer.update(with: drinks(["Zombie", "Negroni"]))
        await indexer.update(with: list)

        #expect(index.indexedBatches.count == 2)
        #expect(index.indexedBatches.last?.count == 1)
        #expect(parameterUpdates == 2)
    }
}
