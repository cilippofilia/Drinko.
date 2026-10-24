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
        let text = CocktailShareMessage.text(for: cocktail(id: "white-lady", name: "White Lady"))
        let link = CocktailClipLink.url(for: "white-lady").absoluteString
        #expect(text == "Tonight's pour: White Lady 🍸\nHere's how to make it:\n\(link)")
    }

    @Test func remoteOnlyCocktailHasNoClipLink() {
        #expect(CocktailShareMessage.text(for: cocktail(id: "remote-only-drink", name: "Remote")) == nil)
    }

    @Test func userCocktailHasNoMessage() {
        #expect(CocktailShareMessage.text(for: cocktail(id: "user-1234", name: "Mine")) == nil)
    }
}
