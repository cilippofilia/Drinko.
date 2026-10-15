import Testing
@testable import DrinkoPro

@Suite("Main spirit")
@MainActor
struct MainSpiritTests {
    private func ingredient(_ name: String, _ quantity: Double, _ unit: String = "oz.") -> Ingredient {
        Ingredient(name: name, quantity: quantity, unit: unit)
    }

    @Test(arguments: [
        ("London Dry Gin", MainSpirit.gin),
        ("Ginger Beer", nil),
        ("Wodka", .vodka),
        ("Zitronenwodka", .vodka),
        ("Bourbon", .whiskey),
        ("Whisky écossais", .whiskey),
        ("Ron blanco", .rum),
        ("Kokosrum", .rum),
        ("cachaca", .rum),
        ("Mezcal", .tequila),
        ("Coñac", .cognac),
        ("Pear & Cognac Liqueur", .liqueur),
        ("Liquore all'amaretto", .liqueur),
        ("Crème de cassis", .liqueur),
        ("Aperol", .liqueur),
        ("Succo di lime", .juice),
        ("Jus d'orange", .juice),
        ("Ananassaft", .juice),
        ("Grenadinesirup", .syrup),
        ("orgeat (almond syrup)", .syrup),
        ("Sweet Red Vermouth", nil)
    ] as [(String, MainSpirit?)])
    func recognizesIngredientsInEveryLanguage(name: String, expected: MainSpirit?) {
        #expect(MainSpirit(ingredientName: name) == expected)
    }

    @Test func spiritsOutrankLiqueursJuicesAndSyrups() {
        let ingredients = [
            ingredient("lime juice", 1),
            ingredient("simple syrup", 1),
            ingredient("cointreau", 1),
            ingredient("blanco tequila", 0.5)
        ]
        #expect(MainSpirit(ingredients: ingredients) == .tequila)
    }

    @Test func largestPourWinsWithinARank() {
        let ingredients = [ingredient("white rum", 0.5), ingredient("bourbon", 1.5)]
        #expect(MainSpirit(ingredients: ingredients) == .whiskey)
    }

    @Test func firstListedWinsATie() {
        let ingredients = [ingredient("vodka", 1), ingredient("london dry gin", 1)]
        #expect(MainSpirit(ingredients: ingredients) == .vodka)
    }

    @Test func drinksWithoutAKnownFamilyHaveNoMainSpirit() {
        #expect(MainSpirit(ingredients: [ingredient("prosecco", 3), ingredient("soda water", 1)]) == nil)
    }

    @Test func suggestedCategoriesShareTheMainSpiritColors() {
        #expect(Category.suggestedCategories.map(\.color) == MainSpirit.allCases.map(\.colorName))
    }
}
