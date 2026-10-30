import Foundation
import Testing
@testable import DrinkoPro

@Suite("RecipeBottle") struct RecipeBottleTests {
    @Test(arguments: ["lime juice", "simple syrup", "egg white", "mint leaves", "ginger beer", "soda water",
                      "orange blossom water", "heavy cream", "espresso", "sugar cube", "hot sauce",
                      "orgeat (almond syrup)"])
    func staples(_ name: String) { #expect(RecipeBottle(name: name) == .staple) }

    @Test func bottles() {
        #expect(RecipeBottle(name: "london dry gin") == .spirit(.gin))
        #expect(RecipeBottle(name: "falernum") == .style(.falernum))
        #expect(RecipeBottle(name: "maraschino liqueur") == .style(.maraschino))
        #expect(RecipeBottle(name: "onion brine") == .staple)
        #expect(RecipeBottle(name: "ginger liqueur") != .spirit(.gin))
        #expect(RecipeBottle(name: "chocolate bitters") != .staple)
        #expect(RecipeBottle(name: "irish cream liqueur") != .staple)
        #expect(RecipeBottle(name: "Some Rare Amaro") == .other("some rare amaro"))
    }

    @Test(arguments: ["cream sherry", "lemon bitters", "ginger liqueur", "coconut rum", "lemon vodka", "orange wine"])
    func kitchenWordsInsideABottleStayBottles(_ name: String) {
        #expect(RecipeBottle(name: name) != .staple)
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
                if case .other = RecipeBottle(name: alternative) { isOther = true }
                #expect(!isOther, "Unclassified ingredient: \(alternative)")
            }
        }
    }
}
