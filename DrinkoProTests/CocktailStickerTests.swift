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

    @Test func shotsShowTheirSticker() throws {
        for id in ["blow-job", "liquirice-shot"] {
            guard case .sticker(let url, _) = viewModel.cardModel(for: try drink(id)).image else {
                Issue.record("\(id) has no sticker")
                continue
            }
            #expect(url == stickerURL(id))
        }
    }

    @Test func stickerIsTintedWithTheMainSpiritsColor() throws {
        // A Blow Job is Kahlua, Bailey's and cream, so it takes the liqueur color.
        let image = viewModel.cardModel(for: try drink("blow-job")).image
        #expect(image == .sticker(stickerURL("blow-job"), tint: MainSpirit.liqueur.colorName))
    }
}
