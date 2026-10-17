import Foundation
import SwiftUI
import Testing
@testable import DrinkoPro

/// The widget decodes its own copy of the drinks, so these check it matches the app's cards.
@Suite("Widget stickers")
@MainActor
struct WidgetStickerTests {
    private let viewModel = CocktailsViewModel()

    private var widgetDrinks: [WidgetCocktail] {
        Bundle.main.decode([WidgetCocktail].self, from: "cocktails.json")
            + Bundle.main.decode([WidgetCocktail].self, from: "shots.json")
    }

    @Test func everyDrinkUsesTheAppsSticker() throws {
        let drinks = widgetDrinks
        #expect(!drinks.isEmpty)

        for drink in drinks {
            let appDrink = try #require(viewModel.listOfAllDrinks.first { $0.id == drink.id })
            #expect(drink.stickerURL == appDrink.stickerURL, "\(drink.id)")
        }
    }

    @Test func everyDrinkUsesTheAppsTint() throws {
        for drink in widgetDrinks {
            let appDrink = try #require(viewModel.listOfAllDrinks.first { $0.id == drink.id })
            #expect(drink.mainSpirit?.colorName == viewModel.stickerTint(for: appDrink), "\(drink.id)")
        }
    }

    @Test func ouncesAreConvertedToMilliliters() {
        #expect(WidgetIngredient(name: "Gin", quantity: 1.5, unit: "oz.").milliliters == 45)
        #expect(WidgetIngredient(name: "Bitters", quantity: 2, unit: "dashes").milliliters == 2)
    }

    @Test func ingredientListJoinsNamesInPouringOrder() {
        let drink = WidgetCocktail(
            id: "test", name: "Test", method: "-", glass: "-", garnish: "-", ice: "-", extra: "-",
            ingredients: [
                .init(name: "prosecco", quantity: 3, unit: "oz."),
                .init(name: "aperol", quantity: 2, unit: "oz.")
            ]
        )
        #expect(drink.ingredientList == "Prosecco · Aperol")
    }

    @Test func downsampledStickerFitsTheWidgetLimit() throws {
        let original = try #require(Self.makePNG(width: 563, height: 1200))
        let data = try #require(DrinkoWidgetImageStore.downsampledPNG(from: original))
        let image = try #require(UIImage(data: data))

        #expect(max(image.size.width * image.scale, image.size.height * image.scale)
            <= CGFloat(DrinkoWidgetImageStore.maxStickerPixelSize))
    }

    private static func makePNG(width: Int, height: Int) -> Data? {
        let renderer = ImageRenderer(content: Color.orange.frame(width: CGFloat(width), height: CGFloat(height)))
        renderer.scale = 1
        return renderer.uiImage?.pngData()
    }
}
