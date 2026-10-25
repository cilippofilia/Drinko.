//
//  RemoteCocktailCatalogTests.swift
//  DrinkoProTests
//

import Foundation
import Testing
@testable import DrinkoPro

@MainActor
struct RemoteCocktailCatalogTests {
    private let language = "en"

    private func json<T: Encodable>(_ values: [T]) throws -> Data {
        try JSONEncoder().encode(values)
    }

    private func cocktail(_ id: String) throws -> Cocktail {
        let json = #"{"id":"\#(id)","name":"\#(id)","method":"Stir","glass":"coupe","#
            + #""garnish":"","ice":"","extra":"","ingredients":[]}"#
        let data = Data(json.utf8)
        return try JSONDecoder().decode(Cocktail.self, from: data)
    }

    private func script(
        _ fetcher: FakeContentFetcher,
        _ file: ContentFile,
        _ data: Data
    ) {
        fetcher.script(file.remotePath(language: language), .success(.modified(data, etag: nil)))
    }

    private func load(_ fetcher: FakeContentFetcher) async -> BundledCocktailCatalog? {
        let loader = ReadOnlyContentLoader(cache: nil, fetcher: fetcher, language: language)
        return await RemoteCocktailCatalog.load(loader: loader)
    }

    @Test func nilWhenShotsFail() async throws {
        let fetcher = FakeContentFetcher()
        script(fetcher, .cocktails, try json([cocktail("remote-only")]))
        #expect(await load(fetcher) == nil)
    }

    @Test func usesRemoteCocktailsAndBundledHistoryWhenHistoryFails() async throws {
        let fetcher = FakeContentFetcher()
        script(fetcher, .cocktails, try json([cocktail("negroni")]))
        script(fetcher, .shots, try json([cocktail("remote-shot")]))
        let catalog = try #require(await load(fetcher))
        #expect(catalog.cocktail(withID: "remote-shot") != nil)
        let negroni = try #require(catalog.cocktail(withID: "negroni"))
        #expect(catalog.history(for: negroni)?.id == "negroni")
        #expect(catalog.procedure(for: negroni)?.id == "negroni")
    }

    @Test func usesRemoteHistoryWhenValid() async throws {
        let fetcher = FakeContentFetcher()
        script(fetcher, .cocktails, try json([cocktail("negroni")]))
        script(fetcher, .shots, try json([cocktail("remote-shot")]))
        script(fetcher, .history, try json([History(id: "negroni", text: "Remote history")]))
        let catalog = try #require(await load(fetcher))
        let negroni = try #require(catalog.cocktail(withID: "negroni"))
        #expect(catalog.history(for: negroni)?.text == "Remote history")
    }
}
