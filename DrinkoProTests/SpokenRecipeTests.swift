import Foundation
import Testing
@testable import DrinkoPro

@MainActor
@Suite("SpokenRecipe")
struct SpokenRecipeTests {
    private let english = Locale(identifier: "en_US")

    private let zombie = Cocktail(
        id: "zombie", name: "Zombie (1934)", method: "swizzle/churn", glass: "tiki",
        garnish: "flaming half lime, cinnamon stick, whatever other cool stuff on top",
        ice: "crushed ice", extra: "-",
        ingredients: [
            Ingredient(name: "aged jamaican rum", quantity: 1.5, unit: "oz."),
            Ingredient(name: "lime juice", quantity: 0.75, unit: "oz."),
            Ingredient(name: "granadine", quantity: 0.15, unit: "oz."),
            Ingredient(name: "absinthe", quantity: 3, unit: "dashes")
        ]
    )

    private func make(garnish: String = "-", ingredients: [Ingredient]) -> Cocktail {
        Cocktail(id: "x", name: "X", method: "stir", glass: "coupe", garnish: garnish, ice: "-", extra: "-", ingredients: ingredients)
    }

    @Test
    func halvesAndQuartersAreWords() {
        #expect(SpokenRecipe.spokenAmount(1.5, unit: "oz.", locale: english) == "1 and a half ounces")
        #expect(SpokenRecipe.spokenAmount(0.5, unit: "oz.", locale: english) == "half an ounce")
        #expect(SpokenRecipe.spokenAmount(0.75, unit: "oz.", locale: english) == "three quarters of an ounce")
        #expect(SpokenRecipe.spokenAmount(1, unit: "oz.", locale: english) == "1 ounce")
    }

    @Test
    func oddFractionsStayDecimal() {
        #expect(SpokenRecipe.spokenAmount(0.15, unit: "oz.", locale: english) == "0.15 ounces")
    }

    @Test
    func dashesAreCounted() {
        #expect(SpokenRecipe.spokenAmount(3, unit: "dashes", locale: english) == "3 dashes")
        #expect(SpokenRecipe.spokenAmount(1, unit: "dashes", locale: english) == "1 dash")
    }

    @Test
    func zeroQuantityHasNoAmount() {
        let cocktail = make(ingredients: [Ingredient(name: "soda water", quantity: 0, unit: "oz.")])
        let speech = SpokenRecipe(cocktail: cocktail, steps: [], unit: "oz.", locale: english).ingredientsSpeech
        #expect(speech.hasSuffix("soda water."))
        #expect(!speech.contains("0"))
    }

    @Test
    func displayQuantityMatchesWhatIsSpoken() {
        #expect(SpokenRecipe.displayQuantity(22.5, unit: "ml") == 23)
        #expect(SpokenRecipe.displayQuantity(0.75, unit: "oz.") == 0.75)
    }

    @Test
    func millilitresAreWholeNumbers() {
        #expect(SpokenRecipe.spokenAmount(45, unit: "ml", locale: english) == "45 millilitres")
    }

    @Test
    func ozUserHearsOuncesForMlRecipe() {
        let cocktail = make(ingredients: [Ingredient(name: "gin", quantity: 30, unit: "ml")])
        let speech = SpokenRecipe(cocktail: cocktail, steps: [], unit: "oz.", locale: english).ingredientsSpeech
        #expect(speech.contains("1 ounce gin"))
    }

    @Test
    func ingredientsSpeechOrder() {
        let speech = SpokenRecipe(cocktail: zombie, steps: [], unit: "oz.", locale: english).ingredientsSpeech
        #expect(speech.hasPrefix("Zombie. Tiki glass, crushed ice. 1 and a half ounces aged jamaican rum"))
        #expect(speech.hasSuffix("3 dashes absinthe."))
    }

    @Test
    func methodSpeechEndsWithGarnish() {
        let recipe = SpokenRecipe(cocktail: zombie, steps: ["Shake.", "Strain"], unit: "oz.", locale: english)
        #expect(recipe.methodSpeech.hasPrefix("Step 1: Shake. Step 2: Strain."))
        #expect(recipe.methodSpeech.hasSuffix("Garnish: flaming half lime, cinnamon stick, whatever other cool stuff on top."))
    }

    @Test
    func methodSpeechSkipsDashGarnish() {
        let cocktail = make(garnish: "-", ingredients: [])
        let speech = SpokenRecipe(cocktail: cocktail, steps: ["Stir."], unit: "oz.", locale: english).methodSpeech
        #expect(speech == "Step 1: Stir.")
    }

    @Test
    func italianLineUsesDi() {
        let cocktail = make(ingredients: [Ingredient(name: "gin", quantity: 1.5, unit: "oz.")])
        let speech = SpokenRecipe(cocktail: cocktail, steps: [], unit: "oz.", locale: Locale(identifier: "it_IT")).ingredientsSpeech
        #expect(speech.contains("e mezza"))
        #expect(speech.contains(" di gin"))
    }

    @Test
    func italianPlainUnitsHaveNoConnector() {
        let italian = Locale(identifier: "it_IT")
        let limes = make(ingredients: [Ingredient(name: "lime", quantity: 2, unit: "-")])
        let limeSpeech = SpokenRecipe(cocktail: limes, steps: [], unit: "oz.", locale: italian).ingredientsSpeech
        #expect(limeSpeech.contains("2 lime"))
        #expect(!limeSpeech.contains("di"))

        let mint = make(ingredients: [Ingredient(name: "mint", quantity: 8, unit: "leaves")])
        let mintSpeech = SpokenRecipe(cocktail: mint, steps: [], unit: "oz.", locale: italian).ingredientsSpeech
        #expect(mintSpeech.contains("8 leaves mint"))
        #expect(!mintSpeech.contains("di"))
    }

    @Test
    func tinyQuantitiesAreSpokenByNameOnly() {
        let cocktail = make(ingredients: [Ingredient(name: "salt", quantity: 0.001, unit: "oz.")])
        let speech = SpokenRecipe(cocktail: cocktail, steps: [], unit: "oz.", locale: english).ingredientsSpeech
        #expect(speech.hasSuffix("salt."))
        #expect(!speech.contains("0"))
    }

    @Test
    func noIngredientsEndsWithOneFullStop() {
        let recipe = SpokenRecipe(cocktail: make(ingredients: []), steps: [], unit: "oz.", locale: english)
        #expect(recipe.ingredientsSpeech == "X. Coupe glass.")
    }

    @Test
    func frenchAndSpanishLinesUseDe() {
        let cocktail = make(ingredients: [Ingredient(name: "gin", quantity: 1, unit: "oz.")])
        for identifier in ["fr_FR", "es_ES"] {
            let locale = Locale(identifier: identifier)
            let speech = SpokenRecipe(cocktail: cocktail, steps: [], unit: "oz.", locale: locale).ingredientsSpeech
            #expect(speech.contains(" de gin"))
        }
    }
}
