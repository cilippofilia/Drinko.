import Foundation
import Testing
@testable import DrinkoPro

@MainActor
@Suite("Cocktail glass artwork")
struct CocktailGlassArtworkTests {
    private func cocktail(glass: String) -> Cocktail {
        Cocktail(
            id: "user-test",
            name: "Test",
            method: "build",
            glass: glass,
            garnish: "-",
            ice: "-",
            extra: "-",
            ingredients: []
        )
    }

    @Test func wineUsesTheWineglassSymbol() {
        #expect(cocktail(glass: "wine").glassArtwork == .symbol("wineglass"))
    }

    @Test(arguments: ["coffee mug", "julep cup"])
    func mugsUseTheJulepAsset(glass: String) {
        #expect(cocktail(glass: glass).glassArtwork == .asset("julep"))
    }

    @Test func highballUsesTheCollinsAsset() {
        #expect(cocktail(glass: "highball").glassArtwork == .asset("collins"))
    }

    @Test(arguments: ["coupe", "rock", "nick-nora", "tiki"])
    func otherGlassesUseTheirOwnAsset(glass: String) {
        #expect(cocktail(glass: glass).glassArtwork == .asset(glass))
    }

    @Test func libraryRowsOfUserCocktailsUseGlassArtwork() {
        let viewModel = CocktailsViewModel()
        let userCocktail = cocktail(glass: "wine")
        #expect(viewModel.cardModel(for: userCocktail).image == .glass(userCocktail.glassArtwork, tint: nil))
    }
}
