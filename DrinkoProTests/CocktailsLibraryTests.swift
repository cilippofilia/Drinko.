import Foundation
import SwiftUI
import Testing
@testable import DrinkoPro

@MainActor
@Suite("Cocktails library content")
struct CocktailsLibraryTests {
    private func userCocktail(glass: String) -> Cocktail {
        Cocktail(
            id: "user-test-\(glass)",
            name: "Mine",
            method: "stir",
            glass: glass,
            garnish: "-",
            ice: "-",
            extra: "-",
            ingredients: []
        )
    }

    @Test(arguments: [SortOption.fromAtoZ, .fromZtoA, .byGlass, .byIce])
    func sectionsMatchExistingGrouping(sortOption: SortOption) {
        let viewModel = CocktailsViewModel()
        viewModel.sortOption = sortOption

        let sections = viewModel.librarySections(filterOption: .all) { _ in false }
        let keys = viewModel.sortedSectionKeys(filterOption: .all) { _ in false }
        let grouped = viewModel.groupedCocktails(filterOption: .all) { _ in false }

        #expect(sections.map(\.id) == keys)
        #expect(sections.map(\.title) == keys)
        #expect(sections.map(\.items) == keys.map { grouped[$0] ?? [] })
    }

    @Test func sectionsRespectFilterAndSource() {
        let viewModel = CocktailsViewModel()
        let sections = viewModel.librarySections(filterOption: .shotsOnly, source: .appOnly) { _ in false }
        let shotIDs = Set(viewModel.listOfShots.map(\.id))

        #expect(!sections.isEmpty)
        #expect(sections.flatMap(\.items).allSatisfy { shotIDs.contains($0.id) })
    }

    @Test func searchKeepsGrouping() throws {
        let viewModel = CocktailsViewModel()
        let first = try #require(viewModel.listOfCocktails.first)
        viewModel.searchText = first.name

        let sections = viewModel.librarySections(filterOption: .all) { _ in false }
        #expect(sections.flatMap(\.items).contains(first))
        #expect(sections.map(\.id) == viewModel.sortedSectionKeys(filterOption: .all) { _ in false })
    }

    @Test func appCocktailCardIsTitleOnlySticker() throws {
        let viewModel = CocktailsViewModel()
        let cocktail = try #require(viewModel.listOfCocktails.first)
        let model = viewModel.cardModel(for: cocktail)

        #expect(model.title == cocktail.name)
        #expect(model.subtitle == nil)
        #expect(model.progress == nil)
        #expect(model.image == .sticker(cocktail.stickerURL, tint: MainSpirit(ingredients: cocktail.ingredients)?.colorName))
        #expect(model.imageContentMode == .fit)
    }

    @Test func cardShowsFavoriteOnlyWhenFavorited() throws {
        let viewModel = CocktailsViewModel()
        let cocktail = try #require(viewModel.listOfCocktails.first)

        #expect(viewModel.cardModel(for: cocktail).isFavorite == false)
        #expect(viewModel.cardModel(for: cocktail, isFavorite: true).isFavorite)
    }

    @Test func userCocktailCardsUseGlassArtwork() {
        let viewModel = CocktailsViewModel()
        #expect(viewModel.cardModel(for: userCocktail(glass: "wine")).image == .symbol("wineglass"))
        #expect(viewModel.cardModel(for: userCocktail(glass: "julep cup")).image == .asset("julep"))
        #expect(viewModel.cardModel(for: userCocktail(glass: "coffee mug")).image == .asset("julep"))
        #expect(viewModel.cardModel(for: userCocktail(glass: "coupe")).image == .asset("coupe"))
    }

    @Test func recentItemsDropUnknownIDs() throws {
        let viewModel = CocktailsViewModel()
        let first = try #require(viewModel.listOfCocktails.first)
        let shot = try #require(viewModel.listOfShots.first)

        let items = viewModel.recentItems(from: [shot.id, "user-deleted", first.id])
        #expect(items == [shot, first])
    }

    @Test(arguments: [
        (SortOption.fromAtoZ, ["A", "B", "#"]),
        (.fromZtoA, ["B", "A", "#"]),
        // The "#"-last rule only applies to name sorts.
        (.byGlass, ["#", "A", "B"]),
        (.byIce, ["#", "A", "B"])
    ])
    func sortSectionKeysKeepsHashLastOnlyForNameSorts(sortOption: SortOption, expected: [String]) {
        let viewModel = CocktailsViewModel()
        viewModel.sortOption = sortOption

        #expect(viewModel.sortSectionKeys(["#", "B", "A"]) == expected)
    }

    @Test func stickerTintIsCachedPerCocktail() throws {
        let viewModel = CocktailsViewModel()
        let cocktail = try #require(viewModel.listOfCocktails.first { !$0.ingredients.isEmpty })
        let expectedTint = MainSpirit(ingredients: cocktail.ingredients)?.colorName

        let first = viewModel.cardModel(for: cocktail)
        let second = viewModel.cardModel(for: cocktail)

        #expect(first.image == .sticker(cocktail.stickerURL, tint: expectedTint))
        #expect(second.image == .sticker(cocktail.stickerURL, tint: expectedTint))
        #expect(viewModel.stickerTintCache[cocktail.id] != nil)
    }
}
