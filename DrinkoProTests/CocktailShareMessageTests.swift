//
//  CocktailShareMessageTests.swift
//  DrinkoProTests
//

import Foundation
import Testing
@testable import DrinkoPro

@Suite("CocktailShareMessage")
struct CocktailShareMessageTests {
    private func cocktail(id: String, name: String) -> Cocktail {
        Cocktail(id: id, name: name, method: "stir", glass: "rock", garnish: "-", ice: "cubed", extra: "-", ingredients: [])
    }

    @Test func firstVariantKeepsTheOriginalWording() {
        let text = CocktailShareMessage.text(for: cocktail(id: "white-lady", name: "White Lady"), variant: 0)
        let link = CocktailClipLink.url(for: "white-lady").absoluteString
        #expect(text == "Tonight's pour: White Lady 🍸\nHere's how to make it:\n\(link)")
    }

    @Test func everyVariantHasTheNameAndLink() {
        let link = CocktailClipLink.url(for: "white-lady").absoluteString
        for variant in 0..<CocktailShareMessage.variantCount {
            let text = CocktailShareMessage.text(for: cocktail(id: "white-lady", name: "White Lady"), variant: variant)
            #expect(text?.contains("White Lady") == true)
            #expect(text?.hasSuffix(link) == true)
        }
    }

    @Test func variantsAreAllDifferent() {
        let templates = CocktailShareMessage.templates(name: "White Lady", link: "https://example.com")
        #expect(templates.count > 1)
        #expect(Set(templates).count == templates.count)
    }

    @Test func outOfRangeVariantWrapsAround() {
        let drink = cocktail(id: "white-lady", name: "White Lady")
        let count = CocktailShareMessage.variantCount
        let text = { CocktailShareMessage.text(for: drink, variant: $0) }
        #expect(text(count + 1) == text(1))
        #expect(text(-1) == text(count - 1))
    }

    @Test func randomVariantIsInRange() {
        for _ in 0..<50 {
            #expect((0..<CocktailShareMessage.variantCount).contains(CocktailShareMessage.randomVariant()))
        }
    }

    @Test func downloadedCocktailIncludesLink() {
        let text = CocktailShareMessage.text(for: cocktail(id: "brand-new-sour", name: "Brand New Sour"), variant: 0)
        let link = CocktailClipLink.url(for: "brand-new-sour").absoluteString
        #expect(text?.contains(link) == true)
    }

    @Test func userCocktailHasNoMessage() {
        #expect(CocktailShareMessage.text(for: cocktail(id: "user-1234", name: "Mine"), variant: 0) == nil)
    }
}
