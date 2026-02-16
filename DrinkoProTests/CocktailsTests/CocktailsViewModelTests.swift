import XCTest
@testable import DrinkoPro

@MainActor
final class CocktailsViewModelTests: XCTestCase {
    func testBundleDataLoads() {
        let viewModel = CocktailsViewModel()

        XCTAssertEqual(viewModel.listOfCocktails.count, 2)
        XCTAssertEqual(viewModel.listOfShots.count, 1)
        XCTAssertEqual(viewModel.histories.count, 1)
        XCTAssertEqual(viewModel.procedures.count, 1)
        XCTAssertEqual(viewModel.listOfAllDrinks.count, 3)
    }

    func testSortedCocktailsFromAtoZ() {
        let viewModel = CocktailsViewModel()
        viewModel.sortOption = .fromAtoZ

        let names = viewModel.sortedCocktails.map(\.name)
        XCTAssertEqual(names, ["Alpha", "Martini", "Shot Z"])
    }

    func testSortedCocktailsByGlass() {
        let viewModel = CocktailsViewModel()
        viewModel.sortOption = .byGlass

        let glasses = viewModel.sortedCocktails.map(\.glass)
        XCTAssertEqual(glasses, ["Coupe", "Highball", "Shot"])
    }

    func testFilteredCocktailsBySearchText() {
        let viewModel = CocktailsViewModel()
        viewModel.searchText = "mart"

        let results = viewModel.filteredCocktails
        XCTAssertEqual(results.map(\.name), ["Martini"])
    }

    func testFilteredCocktailsFavoritesOnly() {
        let viewModel = CocktailsViewModel()
        let favorites = viewModel.filteredCocktails(filterOption: .favoritesOnly) { $0.id == "cocktail-2" }

        XCTAssertEqual(favorites.map(\.id), ["cocktail-2"])
    }

    func testGroupedCocktailsByGlass() {
        let viewModel = CocktailsViewModel()
        viewModel.sortOption = .byGlass

        let grouped = viewModel.groupedCocktails(filterOption: .all) { _ in false }
        XCTAssertEqual(grouped.keys.sorted(), ["Coupe", "Highball", "Shot"])
        XCTAssertEqual(grouped["Coupe"]?.first?.name, "Alpha")
    }

    func testSortedSectionKeysByNameDescending() {
        let viewModel = CocktailsViewModel()
        viewModel.sortOption = .fromZtoA

        let keys = viewModel.sortedSectionKeys(filterOption: .all) { _ in false }
        XCTAssertEqual(keys, ["S", "M", "A"])
    }

    func testHistoryAndProcedureLookup() {
        let viewModel = CocktailsViewModel()
        let cocktail = viewModel.listOfCocktails[0]

        XCTAssertEqual(viewModel.getCocktailHistory(for: cocktail)?.id, "cocktail-1")
        XCTAssertEqual(viewModel.getCocktailProcedure(for: cocktail)?.id, "cocktail-1")
    }

    func testLinkedCocktailsSharesFirstIngredient() {
        let viewModel = CocktailsViewModel()
        let cocktail = viewModel.listOfCocktails[0]

        let linked = viewModel.getLinkedCocktails(for: cocktail)

        XCTAssertTrue(linked.allSatisfy { $0.id != cocktail.id })
        XCTAssertTrue(linked.map(\.id).contains("cocktail-2"))
        XCTAssertLessThanOrEqual(linked.count, 5)
    }
}
