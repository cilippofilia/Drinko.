//
//  CocktailClipLinkTests.swift
//  DrinkoProTests
//

import Foundation
import Testing
@testable import DrinkoPro

@Suite("CocktailClipLink")
struct CocktailClipLinkTests {
    @Test func buildsDefaultAppClipLink() {
        let url = CocktailClipLink.url(for: "negroni")
        #expect(url.absoluteString == "https://appclip.apple.com/id?p=me.cilia.filippo.DrinkoPro.Clip&cocktail=negroni")
    }

    @Test func parsesDefaultAppClipLink() throws {
        let url = try #require(URL(string: "https://appclip.apple.com/id?p=me.cilia.filippo.DrinkoPro.Clip&cocktail=negroni"))
        #expect(CocktailClipLink.cocktailID(from: url) == "negroni")
    }

    @Test func parsesOwnDomainLink() throws {
        let url = try #require(URL(string: "https://drinko.app/c/negroni"))
        #expect(CocktailClipLink.cocktailID(from: url) == "negroni")
    }

    @Test func parsesCustomSchemeLink() throws {
        let url = try #require(URL(string: "drinko://cocktail/negroni"))
        #expect(CocktailClipLink.cocktailID(from: url) == "negroni")
    }

    @Test(arguments: ["gin-martini", "a&b", "what?", "two words"])
    func roundTripsIDsNeedingEncoding(id: String) {
        #expect(CocktailClipLink.cocktailID(from: CocktailClipLink.url(for: id)) == id)
    }

    @Test func rejectsOtherAppClip() throws {
        let url = try #require(URL(string: "https://appclip.apple.com/id?p=com.other.app&cocktail=negroni"))
        #expect(CocktailClipLink.cocktailID(from: url) == nil)
    }

    @Test(arguments: [
        "https://appclip.apple.com/id?p=me.cilia.filippo.DrinkoPro.Clip",
        "https://appclip.apple.com/id?p=me.cilia.filippo.DrinkoPro.Clip&cocktail=",
        "https://drinko.app/c/",
        "https://drinko.app/other/negroni",
        "drinko://cocktail/",
        "drinko://lesson/negroni",
        "https://cocktail/negroni",
        "https://example.com/c/negroni"
    ])
    func rejectsUnsupportedLinks(string: String) throws {
        let url = try #require(URL(string: string))
        #expect(CocktailClipLink.cocktailID(from: url) == nil)
    }

    @Test(arguments: ["https://drinko.app/c/negroni/", "drinko://cocktail/negroni/extra"])
    func toleratesTrailingSlash(string: String) throws {
        let url = try #require(URL(string: string))
        #expect(CocktailClipLink.cocktailID(from: url) == "negroni")
    }
}
