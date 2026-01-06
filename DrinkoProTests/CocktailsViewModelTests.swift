//
//  CocktailsViewModelTests.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 06/01/2026.
//

import Testing
@testable import DrinkoPro

@Suite("CocktailsViewModel sorting, filtering, suggestions")
@MainActor
struct CocktailsViewModelTests {
    private func makeViewModel() -> CocktailsViewModel {
        let vm = CocktailsViewModel()
        // Overwrite with deterministic data to avoid bundle dependencies
        vm.listOfCocktails = [
            Cocktail(
                id: "a-sour",
                name: "Amaretto Sour",
                method: "Shake",
                glass: "Rocks",
                garnish: "Lemon wheel",
                ice: "Cubed",
                extra: "",
                ingredients: [Ingredient(name: "Amaretto", quantity: 1.5, unit: "oz.")]
            ),
            Cocktail(
                id: "z-martini",
                name: "Z Martini",
                method: "Stir",
                glass: "Coupe",
                garnish: "Olive",
                ice: "None",
                extra: "",
                ingredients: [Ingredient(name: "Vodka", quantity: 2.0, unit: "oz.")]
            )
        ]
        vm.listOfShots = [
            Cocktail(
                id: "b-50-50",
                name: "B 50/50",
                method: "Build",
                glass: "Shot",
                garnish: "None",
                ice: "None",
                extra: "",
                ingredients: [Ingredient(name: "Vodka", quantity: 1.0, unit: "oz.")]
            )
        ]
        vm.histories = []
        vm.procedures = []
        return vm
    }

    @Test("Default sort A>Z")
    func defaultSort() async throws {
        let vm = makeViewModel()
        #expect(vm.sortedCocktails.map { $0.name } == ["Amaretto Sour", "B 50/50", "Z Martini"])
    }

    @Test("Sort Z>A")
    func sortZtoA() async throws {
        let vm = makeViewModel()
        vm.sortOption = .fromZtoA
        #expect(vm.sortedCocktails.map { $0.name } == ["Z Martini", "B 50/50", "Amaretto Sour"])
    }

    @Test("Sort by glass groups and keys")
    func sortByGlass() async throws {
        let vm = makeViewModel()
        vm.sortOption = .byGlass
        let keys = vm.sortedSectionKeys
        #expect(keys == ["Coupe", "Rocks", "Shot"])
        #expect(vm.cocktailsGrouped["Rocks"]?.map { $0.name } == ["Amaretto Sour"])
    }

    @Test("Filtering by search text")
    func filtering() async throws {
        let vm = makeViewModel()
        vm.searchText = "mart"
        #expect(vm.filteredCocktails.map { $0.name } == ["Z Martini"])
    }

    @Test("Suggested cocktails by first ingredient")
    func suggestions() async throws {
        let vm = makeViewModel()
        let base = vm.listOfCocktails[1] // Z Martini, first ingredient Vodka
        let suggestions = vm.getLinkedCocktails(for: base)
        // Should not include itself, but include other with Vodka
        #expect(suggestions.contains(where: { $0.id == "b-50-50" }))
        #expect(suggestions.contains(where: { $0.id == base.id }) == false)
    }
}
