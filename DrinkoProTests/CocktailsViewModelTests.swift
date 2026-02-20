import XCTest

#if canImport(DrinkoPro)
@testable import DrinkoPro
#elseif canImport(DrinkoDesktop)
@testable import DrinkoDesktop
#endif

@MainActor
final class CocktailsViewModelTests: XCTestCase {
    func testBundleDataLoads() {
        let viewModel = CocktailsViewModel()

        XCTAssertFalse(viewModel.listOfCocktails.isEmpty)
        XCTAssertFalse(viewModel.listOfShots.isEmpty)
        XCTAssertFalse(viewModel.histories.isEmpty)
        XCTAssertFalse(viewModel.procedures.isEmpty)
        XCTAssertEqual(
            viewModel.listOfAllDrinks.count,
            viewModel.listOfCocktails.count + viewModel.listOfShots.count + viewModel.userCocktails.count
        )
    }

    func testSortedCocktailsFromAtoZ() {
        let viewModel = CocktailsViewModel()
        viewModel.sortOption = .fromAtoZ

        let names = viewModel.sortedCocktails.map(\.name)
        XCTAssertEqual(names, names.sorted())
    }

    func testSortedCocktailsByGlass() {
        let viewModel = CocktailsViewModel()
        viewModel.sortOption = .byGlass

        let glasses = viewModel.sortedCocktails.map(\.glass)
        XCTAssertEqual(glasses, glasses.sorted())
    }

    func testFilteredCocktailsBySearchText() {
        let viewModel = CocktailsViewModel()
        guard let firstName = viewModel.listOfAllDrinks.first?.name else {
            return
        }
        let searchText = String(firstName.prefix(2))
        viewModel.searchText = searchText

        let results = viewModel.filteredCocktails
        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(results.allSatisfy { $0.name.localizedStandardContains(searchText) })
    }

    func testFilteredCocktailsFavoritesOnly() {
        let viewModel = CocktailsViewModel()
        let favoriteIds = Set(viewModel.listOfAllDrinks.prefix(2).map(\.id))
        let favorites = viewModel.filteredCocktails(filterOption: .favoritesOnly) { favoriteIds.contains($0.id) }

        XCTAssertTrue(favorites.allSatisfy { favoriteIds.contains($0.id) })
    }

    func testGroupedCocktailsByGlass() {
        let viewModel = CocktailsViewModel()
        viewModel.sortOption = .byGlass

        let grouped = viewModel.groupedCocktails(filterOption: .all) { _ in false }
        XCTAssertFalse(grouped.isEmpty)
        XCTAssertTrue(grouped.values.allSatisfy { $0.map(\.name) == $0.map(\.name).sorted() })
    }

    func testSortedSectionKeysByNameDescending() {
        let viewModel = CocktailsViewModel()
        viewModel.sortOption = .fromZtoA

        let keys = viewModel.sortedSectionKeys(filterOption: .all) { _ in false }
        XCTAssertEqual(keys, keys.sorted(by: >))
    }

    func testHistoryAndProcedureLookup() {
        let viewModel = CocktailsViewModel()
        guard
            let historyId = viewModel.histories.first?.id,
            let cocktail = viewModel.listOfAllDrinks.first(where: { $0.id == historyId })
        else {
            return
        }

        XCTAssertEqual(viewModel.getCocktailHistory(for: cocktail)?.id, cocktail.id)

        if let procedureId = viewModel.procedures.first?.id,
           let procedureCocktail = viewModel.listOfAllDrinks.first(where: { $0.id == procedureId }) {
            XCTAssertEqual(viewModel.getCocktailProcedure(for: procedureCocktail)?.id, procedureCocktail.id)
        }
    }

    func testLinkedCocktailsSharesFirstIngredient() {
        let viewModel = CocktailsViewModel()
        guard let cocktail = viewModel.listOfAllDrinks.first else {
            XCTFail("Expected at least one drink in list.")
            return
        }
        guard let ingredient = cocktail.ingredients.first?.name else {
            XCTSkip("No ingredients available to evaluate linked cocktails.")
            return
        }

        let linked = viewModel.getLinkedCocktails(for: cocktail)

        XCTAssertTrue(linked.allSatisfy { $0.id != cocktail.id })
        XCTAssertTrue(linked.allSatisfy { linkedCocktail in
            linkedCocktail.ingredients.contains { $0.name.contains(ingredient) }
        })
        XCTAssertLessThanOrEqual(linked.count, 5)
    }
}
