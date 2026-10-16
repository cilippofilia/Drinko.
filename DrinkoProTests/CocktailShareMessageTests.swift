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

    @Test func builtInCocktailIncludesLink() {
        let text = CocktailShareMessage.text(for: cocktail(id: "negroni", name: "Negroni"))
        #expect(text == "Negroni on Drinko: \(CocktailClipLink.url(for: "negroni").absoluteString)")
    }

    @Test func userCocktailHasNoMessage() {
        #expect(CocktailShareMessage.text(for: cocktail(id: "user-1234", name: "Mine")) == nil)
    }
}
