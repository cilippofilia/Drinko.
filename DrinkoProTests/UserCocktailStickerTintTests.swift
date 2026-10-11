import Foundation
import SwiftData
import Testing
@testable import DrinkoPro

@MainActor
@Suite("User cocktail sticker tint")
struct UserCocktailStickerTintTests {
    private func details(spirit: String) -> UserCocktailDetails {
        UserCocktailDetails(
            name: "House Special",
            method: "shake & fine strain",
            glass: "coupe",
            garnish: "",
            ice: "none",
            extra: "",
            ingredients: [Ingredient(name: spirit, quantity: 2, unit: "oz.")],
            procedureSteps: []
        )
    }

    @Test func editingAUserCocktailRefreshesItsTint() throws {
        let container = try ModelContainer(
            for: UserCreatedCocktail.self,
            UserIngredient.self,
            UserProcedure.self,
            UserProcedureStep.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        )
        let viewModel = CocktailsViewModel()
        viewModel.configure(modelContext: container.mainContext)
        viewModel.addUserCocktail(details(spirit: "Rum"))
        let original = try #require(viewModel.userCocktails.first)
        #expect(viewModel.stickerTint(for: original) == MainSpirit.rum.colorName)

        viewModel.updateUserCocktail(original, with: details(spirit: "Gin"))

        let edited = try #require(viewModel.userCocktails.first)
        #expect(viewModel.stickerTint(for: edited) == MainSpirit.gin.colorName)
    }
}
