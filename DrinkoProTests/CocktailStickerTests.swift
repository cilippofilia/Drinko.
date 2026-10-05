import Foundation
import Testing
@testable import DrinkoPro

@Suite("Cocktail stickers")
@MainActor
struct CocktailStickerTests {
    private let viewModel = CocktailsViewModel()

    private func drink(_ id: String) throws -> Cocktail {
        try #require(viewModel.listOfAllDrinks.first { $0.id == id })
    }

    private func stickerURL(_ name: String) -> URL? {
        URL(string: "https://raw.githubusercontent.com/cilippofilia/Drinko-stickers/main/drinko-\(name).png")
    }

    @Test func stickerSharesTheCocktailsID() throws {
        #expect(try drink("aperol-spritz").stickerURL == stickerURL("aperol-spritz"))
    }

    @Test func someCocktailsUseAStickerFiledUnderAnotherName() throws {
        #expect(try drink("augie-march").stickerURL == stickerURL("manhattan"))
        #expect(try drink("gin-martini").stickerURL == stickerURL("dry-martini"))
    }

    @Test func drinksWithoutAStickerKeepTheirPhoto() throws {
        for id in ["blow-job", "irish-car-bomb"] {
            let cocktail = try drink(id)
            #expect(cocktail.stickerURL == nil)
            #expect(viewModel.cardModel(for: cocktail).image == .remote(URL(string: cocktail.pic)))
        }
    }
}
