import SwiftData
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

    func testNamesStartingWithANumberAreListedLast() {
        let viewModel = CocktailsViewModel()

        for sortOption in [SortOption.fromAtoZ, .fromZtoA] {
            viewModel.sortOption = sortOption
            let keys = viewModel.sortedSectionKeys(filterOption: .all) { _ in false }
            let grouped = viewModel.groupedCocktails(filterOption: .all) { _ in false }

            XCTAssertEqual(keys.last, "#")
            XCTAssertTrue(grouped["#"]?.contains { $0.name == "57 T-Bird" } ?? false)
        }
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

    // MARK: - List source

    /// Keeps the in-memory store alive for the duration of a test.
    private var container: ModelContainer?

    override func tearDown() async throws {
        container = nil
        try await super.tearDown()
    }

    /// A view model backed by an in-memory store holding one user cocktail.
    private func makeViewModelWithUserCocktail() throws -> CocktailsViewModel {
        let container = try ModelContainer(
            for: UserCreatedCocktail.self,
            UserIngredient.self,
            UserProcedure.self,
            UserProcedureStep.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        )
        let viewModel = CocktailsViewModel()
        viewModel.configure(modelContext: container.mainContext)
        viewModel.addUserCocktail(UserCocktailDetails(
            name: "House Special",
            method: "shake & fine strain",
            glass: "coupe",
            garnish: "",
            ice: "none",
            extra: "",
            ingredients: [Ingredient(name: "Rum", quantity: 2, unit: "oz.")],
            procedureSteps: []
        ))
        self.container = container
        return viewModel
    }

    func testUserAndAppSourceIncludesEverything() throws {
        let viewModel = try makeViewModelWithUserCocktail()

        let results = viewModel.filteredCocktails(filterOption: .all, source: .userAndApp) { _ in false }

        XCTAssertEqual(results.count, viewModel.listOfAllDrinks.count)
        XCTAssertEqual(viewModel.userCocktails.count, 1)
    }

    func testDefaultSourceMatchesUserAndApp() throws {
        let viewModel = try makeViewModelWithUserCocktail()

        XCTAssertEqual(
            viewModel.filteredCocktails(filterOption: .all) { _ in false },
            viewModel.filteredCocktails(filterOption: .all, source: .userAndApp) { _ in false }
        )
    }

    func testAppOnlySourceExcludesUserCocktails() throws {
        let viewModel = try makeViewModelWithUserCocktail()

        let results = viewModel.filteredCocktails(filterOption: .all, source: .appOnly) { _ in false }

        XCTAssertEqual(results.count, viewModel.listOfCocktails.count + viewModel.listOfShots.count)
        XCTAssertFalse(results.contains { viewModel.isUserCreated($0) })
    }

    func testUserOnlySourceShowsOnlyUserCocktails() throws {
        let viewModel = try makeViewModelWithUserCocktail()

        let results = viewModel.filteredCocktails(filterOption: .all, source: .userOnly) { _ in false }

        XCTAssertEqual(results, viewModel.userCocktails)
    }

    func testSourceAndFilterIntersect() throws {
        let viewModel = try makeViewModelWithUserCocktail()
        let userCocktail = try XCTUnwrap(viewModel.userCocktails.first)
        let appCocktail = try XCTUnwrap(viewModel.listOfCocktails.first)
        let favoriteIDs: Set<String> = [userCocktail.id, appCocktail.id]

        let appFavorites = viewModel.filteredCocktails(filterOption: .favoritesOnly, source: .appOnly) {
            favoriteIDs.contains($0.id)
        }
        let userFavorites = viewModel.filteredCocktails(filterOption: .favoritesOnly, source: .userOnly) {
            favoriteIDs.contains($0.id)
        }
        let appCocktailsOnly = viewModel.filteredCocktails(filterOption: .cocktailsOnly, source: .appOnly) { _ in
            false
        }
        let appUserCreated = viewModel.filteredCocktails(filterOption: .userCreatedOnly, source: .appOnly) { _ in
            false
        }

        XCTAssertEqual(appFavorites, [appCocktail])
        XCTAssertEqual(userFavorites, [userCocktail])
        XCTAssertEqual(appCocktailsOnly.count, viewModel.listOfCocktails.count)
        XCTAssertTrue(appUserCreated.isEmpty)
    }

    func testUserOnlySourceRespectsSearch() throws {
        let viewModel = try makeViewModelWithUserCocktail()

        viewModel.searchText = "house"
        XCTAssertEqual(viewModel.filteredCocktails(filterOption: .all, source: .userOnly) { _ in false }.count, 1)

        viewModel.searchText = "negroni"
        XCTAssertTrue(viewModel.filteredCocktails(filterOption: .all, source: .userOnly) { _ in false }.isEmpty)
    }

    func testAvailableFilterOptionsPerSource() {
        let viewModel = CocktailsViewModel()

        XCTAssertEqual(
            viewModel.availableFilterOptions(for: .userAndApp),
            [.all, .cocktailsOnly, .shotsOnly, .favoritesOnly, .userCreatedOnly]
        )
        XCTAssertEqual(
            viewModel.availableFilterOptions(for: .appOnly),
            [.all, .cocktailsOnly, .shotsOnly, .favoritesOnly]
        )
        XCTAssertEqual(viewModel.availableFilterOptions(for: .userOnly), [.all, .favoritesOnly])
    }

    func testListSourceRawValuesAreStable() {
        // Raw values are persisted in UserDefaults, so they must not change.
        XCTAssertEqual(CocktailListSource.userAndApp.rawValue, "userAndApp")
        XCTAssertEqual(CocktailListSource.appOnly.rawValue, "appOnly")
        XCTAssertEqual(CocktailListSource.userOnly.rawValue, "userOnly")
    }

    // MARK: - Recents cache

    /// Adds a second user cocktail to an already-configured view model.
    private func addSecondUserCocktail(to viewModel: CocktailsViewModel, name: String) {
        viewModel.addUserCocktail(UserCocktailDetails(
            name: name,
            method: "stir",
            glass: "coupe",
            garnish: "",
            ice: "none",
            extra: "",
            ingredients: [],
            procedureSteps: []
        ))
    }

    func testRecentItemsIncludeAUserCocktailAddedAfterTheBundledCacheWarmedUp() throws {
        let viewModel = try makeViewModelWithUserCocktail()
        let bundledID = try XCTUnwrap(viewModel.listOfCocktails.first?.id)

        // Warm the cached bundled-drinks lookup before a second user cocktail is added.
        XCTAssertEqual(viewModel.recentItems(from: [bundledID]).map(\.id), [bundledID])

        addSecondUserCocktail(to: viewModel, name: "Second Special")
        let newUser = try XCTUnwrap(viewModel.userCocktails.first { $0.name == "Second Special" })

        XCTAssertEqual(viewModel.recentItems(from: [newUser.id, bundledID]).map(\.id), [newUser.id, bundledID])
    }

    func testRecentItemsDropAUserCocktailAfterItsDeleted() throws {
        let viewModel = try makeViewModelWithUserCocktail()
        let userCocktail = try XCTUnwrap(viewModel.userCocktails.first)
        XCTAssertEqual(viewModel.recentItems(from: [userCocktail.id]).map(\.id), [userCocktail.id])

        viewModel.deleteUserCocktail(userCocktail)

        XCTAssertTrue(viewModel.recentItems(from: [userCocktail.id]).isEmpty)
    }

    func testRecentItemsReflectAUserCocktailsLatestName() throws {
        let viewModel = try makeViewModelWithUserCocktail()
        let userCocktail = try XCTUnwrap(viewModel.userCocktails.first)

        viewModel.updateUserCocktail(userCocktail, with: UserCocktailDetails(
            name: "Renamed Special",
            method: userCocktail.method,
            glass: userCocktail.glass,
            garnish: userCocktail.garnish,
            ice: userCocktail.ice,
            extra: userCocktail.extra,
            ingredients: userCocktail.ingredients,
            procedureSteps: []
        ))

        let renamed = try XCTUnwrap(viewModel.recentItems(from: [userCocktail.id]).first)
        XCTAssertEqual(renamed.name, "Renamed Special")
    }
}
