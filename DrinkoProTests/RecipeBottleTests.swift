import Foundation
import Testing
@testable import DrinkoPro

@Suite("RecipeBottle") struct RecipeBottleTests {
    @Test(arguments: ["lime juice", "simple syrup", "egg white", "mint leaves", "ginger beer", "soda water",
                      "orange blossom water", "heavy cream", "espresso", "sugar cube", "hot sauce",
                      "orgeat (almond syrup)"])
    func staples(_ name: String) { #expect(RecipeBottle.isStaple(name)) }

    @Test func staplesAreMatchedByNameNeverAsASpirit() {
        #expect(RecipeBottle(name: "ginger beer") == .other("ginger beer"))
        #expect(RecipeBottle(name: "Honey-Syrup") == .other("honey syrup"))
    }

    @Test func bottles() {
        #expect(RecipeBottle(name: "london dry gin") == .spirit(.gin))
        #expect(RecipeBottle(name: "falernum") == .style(.falernum))
        #expect(RecipeBottle(name: "maraschino liqueur") == .style(.maraschino))
        #expect(RecipeBottle.isStaple("onion brine"))
        #expect(RecipeBottle(name: "ginger liqueur") != .spirit(.gin))
        #expect(!RecipeBottle.isStaple("chocolate bitters"))
        #expect(!RecipeBottle.isStaple("irish cream liqueur"))
        #expect(RecipeBottle(name: "Some Rare Amaro") == .other("some rare amaro"))
    }

    @Test(arguments: ["cream sherry", "lemon bitters", "ginger liqueur", "coconut rum", "lemon vodka", "orange wine",
                      "eau de vie de poire", "poire williams eau-de-vie", "Kirsch Wasser"])
    func kitchenWordsInsideABottleStayBottles(_ name: String) {
        #expect(!RecipeBottle.isStaple(name))
    }

    @Test func newStyles() {
        #expect(RecipeBottle(name: "chocolate bitters") == .style(.chocolateBitters))
        #expect(RecipeBottle(name: "framboise") == .style(.cremeDeFramboise))
    }

    @Test func alternatives() {
        #expect(RecipeBottle.alternatives(in: "bourbon or rye whiskey") == ["bourbon", "rye whiskey"])
        #expect(RecipeBottle.alternatives(in: "blended scotch / vodka") == ["blended scotch", "vodka"])
        #expect(RecipeBottle.alternatives(in: "rum (your choice)") == ["rum"])
        #expect(RecipeBottle.alternatives(in: "pinot noir or similar") == ["pinot noir"])
    }

    /// Keeps the staple list and `BottleStyle` complete: a new unclassified ingredient fails here.
    @Test @MainActor func everyCatalogIngredientIsClassified() {
        let cocktails = Bundle.main.decode([Cocktail].self, from: "cocktails.json")
        #expect(!cocktails.isEmpty)

        for ingredient in cocktails.flatMap(\.ingredients) {
            for alternative in RecipeBottle.alternatives(in: ingredient.name) {
                var isOther = false
                if case .other = RecipeBottle(name: alternative) { isOther = !RecipeBottle.isStaple(alternative) }
                #expect(!isOther, "Unclassified ingredient: \(alternative)")
            }
        }
    }

    /// Same check over the bundled shots in every language. A liqueur without a style stays `.other`
    /// on purpose: the Cabinet matches it by name.
    @Test @MainActor func everyShotIngredientIsClassified() throws {
        for language in ["en", "de", "es", "fr", "it"] {
            let url = try #require(
                Bundle.main.url(forResource: "shots", withExtension: "json", subdirectory: nil, localization: language)
            )
            let shots = try JSONDecoder().decode([Cocktail].self, from: Data(contentsOf: url))
            #expect(!shots.isEmpty)
            for ingredient in shots.flatMap(\.ingredients) {
                for alternative in RecipeBottle.alternatives(in: ingredient.name) {
                    var isOther = false
                    if case .other = RecipeBottle(name: alternative) { isOther = !RecipeBottle.isStaple(alternative) }
                    isOther = isOther && MainSpirit(ingredientName: alternative) != .liqueur
                    #expect(!isOther, "Unclassified shot ingredient (\(language)): \(alternative)")
                }
            }
        }
    }

    @Test(arguments: ["Schlagsahne", "Crème fleurette", "Nata para montar", "Filterkaffee (heiß)", "Cordial de lima"])
    func shotStaples(_ name: String) { #expect(RecipeBottle.isStaple(name)) }

    @Test(arguments: [
        ("Maraschino-Likör", BottleStyle.maraschino), ("Liquore maraschino", .maraschino),
        ("Licor de marrasquino", .maraschino), ("Liqueur de marasquin", .maraschino),
        ("Kirschlikör", .cherryHeering), ("Licor de cereza", .cherryHeering),
        ("Liqueur de cerise", .cherryHeering), ("Liquore alla ciliegia", .cherryHeering),
        ("Espressolikör", .coffeeLiqueur)
    ])
    func shotLiqueurTranslations(name: String, style: BottleStyle) {
        #expect(RecipeBottle(name: name) == .style(style))
    }

    @Test func cherryBrandyIsNotACognac() {
        #expect(RecipeBottle(name: "cherry brandy") != .spirit(.cognac))
        #expect(!RecipeBottle.isStaple("Bailey's Irish Cream"))
    }
}
