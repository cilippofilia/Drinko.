import SwiftData
import Testing
@testable import DrinkoPro

@MainActor
@Suite("User cocktail card color")
struct UserCocktailCardColorTests {
    private func makeViewModel() throws -> (CocktailsViewModel, ModelContainer) {
        let container = try ModelContainer(
            for: UserCreatedCocktail.self, UserIngredient.self, UserProcedure.self, UserProcedureStep.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        )
        let viewModel = CocktailsViewModel()
        viewModel.configure(modelContext: container.mainContext)
        return (viewModel, container)
    }

    private func details(ingredient: String, tintColor: String?) -> UserCocktailDetails {
        UserCocktailDetails(
            name: "House Special", method: "stir", glass: "coupe", garnish: "", ice: "none", extra: "",
            ingredients: [Ingredient(name: ingredient, quantity: 2, unit: "oz.")],
            procedureSteps: [], tintColor: tintColor
        )
    }

    @Test func spiritTintBeatsPickedColor() throws {
        let (viewModel, container) = try makeViewModel()
        _ = container
        viewModel.addUserCocktail(details(ingredient: "Gin", tintColor: "Dr. Red"))
        let cocktail = try #require(viewModel.userCocktails.first)

        #expect(viewModel.stickerTint(for: cocktail) == MainSpirit.gin.colorName)
    }

    @Test func pickedColorAppliesWithoutASpirit() throws {
        let (viewModel, container) = try makeViewModel()
        _ = container
        viewModel.addUserCocktail(details(ingredient: "Soda Water", tintColor: "Dr. Red"))
        let cocktail = try #require(viewModel.userCocktails.first)

        #expect(viewModel.stickerTint(for: cocktail) == "Dr. Red")
        #expect(viewModel.pickedTintColor(for: cocktail) == "Dr. Red")
    }

    @Test func noSpiritAndNoPickMeansNoTint() throws {
        let (viewModel, container) = try makeViewModel()
        _ = container
        viewModel.addUserCocktail(details(ingredient: "Soda Water", tintColor: nil))
        let cocktail = try #require(viewModel.userCocktails.first)

        #expect(viewModel.stickerTint(for: cocktail) == nil)
        #expect(viewModel.pickedTintColor(for: cocktail) == nil)
    }

    @Test func pickedColorSurvivesUpdate() throws {
        let (viewModel, container) = try makeViewModel()
        _ = container
        viewModel.addUserCocktail(details(ingredient: "Soda Water", tintColor: "Dr. Red"))
        var cocktail = try #require(viewModel.userCocktails.first)
        #expect(viewModel.stickerTint(for: cocktail) == "Dr. Red")

        viewModel.updateUserCocktail(cocktail, with: details(ingredient: "Soda Water", tintColor: "Dr. Blue"))
        cocktail = try #require(viewModel.userCocktails.first)
        #expect(viewModel.stickerTint(for: cocktail) == "Dr. Blue")

        // The pick stays stored while a spirit overrides it, so it returns if the spirit goes.
        viewModel.updateUserCocktail(cocktail, with: details(ingredient: "Gin", tintColor: "Dr. Blue"))
        cocktail = try #require(viewModel.userCocktails.first)
        #expect(viewModel.stickerTint(for: cocktail) == MainSpirit.gin.colorName)
        viewModel.updateUserCocktail(cocktail, with: details(ingredient: "Soda Water", tintColor: "Dr. Blue"))
        cocktail = try #require(viewModel.userCocktails.first)
        #expect(viewModel.stickerTint(for: cocktail) == "Dr. Blue")
    }

    @Test func cocktailsWithoutAPictureGetTintedGlass() throws {
        let (viewModel, container) = try makeViewModel()
        _ = container
        viewModel.addUserCocktail(details(ingredient: "Soda Water", tintColor: "Dr. Red"))
        let cocktail = try #require(viewModel.userCocktails.first)

        #expect(viewModel.cardModel(for: cocktail).image == .glass(cocktail.glassArtwork, tint: "Dr. Red"))
    }

    @Test func tintedGlassTakesItsTintAsHeroBackdrop() {
        #expect(RecentsHeroLayout.backdrop(for: .glass(.asset("coupe"), tint: "Dr. Red")) == .color("Dr. Red"))
        #expect(RecentsHeroLayout.backdrop(for: .glass(.asset("coupe"), tint: nil)) == .neutral)
    }
}
