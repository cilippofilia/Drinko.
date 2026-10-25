//
//  WidgetContentLoaderTests.swift
//  DrinkoProTests
//

import Foundation
import Testing
@testable import DrinkoPro

struct WidgetContentLoaderTests {
    private let language = "en"
    private let oneDrink = Data((
        #"[{"id":"remote-drink","name":"Remote","method":"Stir","glass":"coupe","garnish":"Lime","#
            + #""ice":"none","extra":"","ingredients":[{"name":"gin","quantity":2,"unit":"oz."}]}]"#
    ).utf8)

    private func makeCache() -> ContentCache {
        ContentCache(root: URL.temporaryDirectory.appending(path: "WidgetContentLoaderTests-\(UUID().uuidString)"))
    }

    private var bundledCocktails: [WidgetCocktail] {
        Bundle.main.decode([WidgetCocktail].self, from: "cocktails.json")
    }

    private var bundledShots: [WidgetCocktail] {
        Bundle.main.decode([WidgetCocktail].self, from: "shots.json")
    }

    @Test func usesCachedCocktailsAndBundledShots() async throws {
        let cache = makeCache()
        try cache.commit(files: [.cocktails: oneDrink], etags: [:], language: language, checkedAt: .now)
        let loader = WidgetContentLoader.make(
            cache: cache,
            fetcher: FakeContentFetcher(),
            allowsNetwork: true,
            language: language
        )
        let drinks = await loader.drinks()
        #expect(drinks.cocktails.map(\.id) == ["remote-drink"])
        #expect(drinks.shots == bundledShots)
    }

    @Test func fetchesWhenCacheMissing() async {
        let fetcher = FakeContentFetcher()
        fetcher.script(ContentFile.cocktails.remotePath(language: language), .success(.modified(oneDrink, etag: nil)))
        let loader = WidgetContentLoader.make(
            cache: makeCache(),
            fetcher: fetcher,
            allowsNetwork: true,
            language: language
        )
        let drinks = await loader.drinks()
        #expect(drinks.cocktails.map(\.id) == ["remote-drink"])
    }

    @Test func offlineFallsBackToBundled() async {
        let loader = WidgetContentLoader(
            loader: ReadOnlyContentLoader(cache: nil, fetcher: nil, language: language)
        )
        let drinks = await loader.drinks()
        #expect(drinks.cocktails == bundledCocktails)
        #expect(drinks.shots == bundledShots)
        #expect(!drinks.cocktails.isEmpty)
    }

    @Test func previewNeverFetches() async {
        let fetcher = FakeContentFetcher()
        let loader = WidgetContentLoader.make(
            cache: makeCache(),
            fetcher: fetcher,
            allowsNetwork: false,
            language: language
        )
        let drinks = await loader.drinks()
        #expect(fetcher.requests.isEmpty)
        #expect(drinks.cocktails.count == bundledCocktails.count)
        #expect(drinks.shots.count == bundledShots.count)
    }

    @Test func widgetCocktailMapsFromCocktail() {
        let cocktail = Cocktail(
            id: "x",
            name: "X",
            method: "Shake",
            glass: "coupe",
            garnish: "Twist",
            ice: "none",
            extra: "Note",
            ingredients: [
                Ingredient(name: "gin", quantity: 2, unit: "oz."),
                Ingredient(name: "lime", quantity: 15, unit: "ml")
            ]
        )
        let widget = WidgetCocktail(cocktail)
        #expect(widget.id == "x")
        #expect(widget.name == "X")
        #expect(widget.method == "Shake")
        #expect(widget.glass == "coupe")
        #expect(widget.garnish == "Twist")
        #expect(widget.ice == "none")
        #expect(widget.extra == "Note")
        #expect(widget.ingredients.map(\.name) == ["gin", "lime"])
        #expect(widget.ingredients.map(\.quantity) == [2, 15])
        #expect(widget.ingredients.map(\.unit) == ["oz.", "ml"])
    }
}
