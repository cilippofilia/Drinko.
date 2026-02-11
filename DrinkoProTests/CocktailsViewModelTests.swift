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
        vm.userCocktails = []
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

    @Test("Filter option: all")
    func filterAll() async throws {
        let vm = makeViewModel()
        let result = vm.filteredCocktails(filterOption: .all) { _ in false }
        #expect(result.map { $0.name } == ["Amaretto Sour", "B 50/50", "Z Martini"])
    }

    @Test("Filter option: cocktails only")
    func filterCocktailsOnly() async throws {
        let vm = makeViewModel()
        let result = vm.filteredCocktails(filterOption: .cocktailsOnly) { _ in false }
        #expect(result.map { $0.name } == ["Amaretto Sour", "Z Martini"])
    }

    @Test("Filter option: shots only")
    func filterShotsOnly() async throws {
        let vm = makeViewModel()
        let result = vm.filteredCocktails(filterOption: .shotsOnly) { _ in false }
        #expect(result.map { $0.name } == ["B 50/50"])
    }

    @Test("Filter option: favorites only")
    func filterFavoritesOnly() async throws {
        let vm = makeViewModel()
        let favoriteIDs: Set<String> = ["b-50-50", "z-martini"]
        let result = vm.filteredCocktails(filterOption: .favoritesOnly) { cocktail in
            favoriteIDs.contains(cocktail.id)
        }
        #expect(result.map { $0.name } == ["B 50/50", "Z Martini"])
    }

    @Test("Filter option: user created only")
    func filterUserCreatedOnly() async throws {
        let vm = makeViewModel()
        vm.userCocktails = [
            Cocktail(
                id: "user-custom-1",
                name: "My Custom Drink",
                method: "Build",
                glass: "Rocks",
                garnish: "Orange peel",
                ice: "Cubed",
                extra: "",
                ingredients: [Ingredient(name: "Gin", quantity: 2.0, unit: "oz.")]
            )
        ]
        let result = vm.filteredCocktails(filterOption: .userCreatedOnly) { _ in false }
        #expect(result.map { $0.name } == ["My Custom Drink"])
    }

    @Test("Favorites filter combines with search")
    func filterFavoritesWithSearch() async throws {
        let vm = makeViewModel()
        vm.searchText = "mart"
        let favoriteIDs: Set<String> = ["b-50-50"]
        let result = vm.filteredCocktails(filterOption: .favoritesOnly) { cocktail in
            favoriteIDs.contains(cocktail.id)
        }
        #expect(result.isEmpty)
    }

    @Test("Grouped keys respect filter option")
    func groupedKeysWithFilter() async throws {
        let vm = makeViewModel()
        vm.sortOption = .byGlass
        let keys = vm.sortedSectionKeys(filterOption: .cocktailsOnly) { _ in false }
        #expect(keys == ["Coupe", "Rocks"])
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

    @Test("User cocktail is appended and visible in lists")
    func addUserCocktail() async throws {
        let vm = makeViewModel()
        vm.addUserCocktail(
            name: "My Custom Drink",
            method: "Build",
            glass: "Rocks",
            garnish: "Orange peel",
            ice: "Cubed",
            extra: "Personal recipe",
            ingredients: [Ingredient(name: "Gin", quantity: 2.0, unit: "oz.")],
            procedureSteps: ["Build over ice and stir"]
        )

        #expect(vm.userCocktails.count == 1)
        #expect(vm.listOfAllDrinks.contains(where: { $0.name == "My Custom Drink" }))
        #expect(vm.filteredCocktails(filterOption: .cocktailsOnly) { _ in false }.contains(where: { $0.name == "My Custom Drink" }))
    }

    @Test("Suggestions return empty when cocktail has no ingredients")
    func suggestionsWithoutIngredients() async throws {
        let vm = makeViewModel()
        let noIngredientsCocktail = Cocktail(
            id: "empty",
            name: "Empty",
            method: "Build",
            glass: "Rocks",
            garnish: "",
            ice: "Cubed",
            extra: "",
            ingredients: []
        )

        #expect(vm.getLinkedCocktails(for: noIngredientsCocktail).isEmpty)
    }

    @Test("User procedure overrides bundled procedure")
    func userProcedurePreferred() async throws {
        let vm = makeViewModel()
        let cocktail = vm.listOfCocktails[0]
        vm.procedures = [
            Procedure(id: cocktail.id, procedure: [Procedure.Steps(step: "Step 1", text: "Bundled")])
        ]
        vm.userProcedures = [
            Procedure(id: cocktail.id, procedure: [Procedure.Steps(step: "Step 1", text: "User")])
        ]

        let procedure = vm.getCocktailProcedure(for: cocktail)
        #expect(procedure?.procedure.first?.text == "User")
    }

    @Test("Update user cocktail replaces data and procedure")
    func updateUserCocktail() async throws {
        let vm = makeViewModel()
        vm.addUserCocktail(
            name: "First",
            method: "Build",
            glass: "Rocks",
            garnish: "",
            ice: "Cubed",
            extra: "",
            ingredients: [Ingredient(name: "Gin", quantity: 2.0, unit: "oz.")],
            procedureSteps: ["Original step"]
        )

        guard let created = vm.userCocktails.first else {
            #expect(false)
            return
        }

        vm.updateUserCocktail(
            created,
            name: "Updated",
            method: "Shake",
            glass: "Coupe",
            garnish: "Lemon",
            ice: "None",
            extra: "",
            ingredients: [Ingredient(name: "Vodka", quantity: 1.0, unit: "oz.")],
            procedureSteps: ["New step 1", "New step 2"]
        )

        let updated = vm.userCocktails.first
        #expect(updated?.name == "Updated")
        #expect(updated?.glass == "Coupe")

        let procedure = vm.getCocktailProcedure(for: updated!)
        #expect(procedure?.procedure.count == 2)
        #expect(procedure?.procedure.first?.text == "New step 1")
    }

    @Test("Update user cocktail clears procedure when steps empty")
    func updateUserCocktailClearsProcedure() async throws {
        let vm = makeViewModel()
        vm.addUserCocktail(
            name: "First",
            method: "Build",
            glass: "Rocks",
            garnish: "",
            ice: "Cubed",
            extra: "",
            ingredients: [Ingredient(name: "Gin", quantity: 2.0, unit: "oz.")],
            procedureSteps: ["Original step"]
        )

        guard let created = vm.userCocktails.first else {
            #expect(false)
            return
        }

        vm.updateUserCocktail(
            created,
            name: "Updated",
            method: "Shake",
            glass: "Coupe",
            garnish: "",
            ice: "None",
            extra: "",
            ingredients: [Ingredient(name: "Vodka", quantity: 1.0, unit: "oz.")],
            procedureSteps: []
        )

        #expect(vm.getCocktailProcedure(for: created) == nil)
    }

    @Test("Delete user cocktail removes cocktail and procedure")
    func deleteUserCocktail() async throws {
        let vm = makeViewModel()
        vm.addUserCocktail(
            name: "To Delete",
            method: "Build",
            glass: "Rocks",
            garnish: "",
            ice: "Cubed",
            extra: "",
            ingredients: [Ingredient(name: "Gin", quantity: 2.0, unit: "oz.")],
            procedureSteps: ["Step 1"]
        )

        guard let created = vm.userCocktails.first else {
            #expect(false)
            return
        }

        vm.deleteUserCocktail(created)
        #expect(vm.userCocktails.isEmpty)
        #expect(vm.userProcedures.isEmpty)
    }

    @Test("User cocktail id is namespaced")
    func userCocktailIDPrefix() async throws {
        let vm = makeViewModel()
        vm.addUserCocktail(
            name: "Custom",
            method: "Build",
            glass: "Rocks",
            garnish: "",
            ice: "Cubed",
            extra: "",
            ingredients: [Ingredient(name: "Gin", quantity: 2.0, unit: "oz.")],
            procedureSteps: []
        )

        let id = vm.userCocktails.first?.id ?? ""
        #expect(id.hasPrefix("user-"))
    }
}
