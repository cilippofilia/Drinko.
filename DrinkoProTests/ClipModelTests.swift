//
//  ClipModelTests.swift
//  DrinkoProTests
//

import Foundation
import Testing
@testable import DrinkoPro

/// A `fetchRemote` stand-in that suspends until the test releases it, without sleeping.
private actor FetchGate {
    private var waiting: [CheckedContinuation<BundledCocktailCatalog?, Never>] = []
    private var result: BundledCocktailCatalog??
    private let startedContinuation: AsyncStream<Void>.Continuation
    let started: AsyncStream<Void>

    init() {
        (started, startedContinuation) = AsyncStream.makeStream()
    }

    func fetch() async -> BundledCocktailCatalog? {
        startedContinuation.yield()
        if let result { return result }
        return await withCheckedContinuation { waiting.append($0) }
    }

    func release(_ catalog: BundledCocktailCatalog?) {
        result = .some(catalog)
        for continuation in waiting { continuation.resume(returning: catalog) }
        waiting = []
    }
}

@MainActor
struct ClipModelTests {
    private func cocktail(_ id: String, name: String? = nil) throws -> Cocktail {
        let json = #"{"id":"\#(id)","name":"\#(name ?? id)","method":"Stir","glass":"coupe","#
            + #""garnish":"","ice":"","extra":"","ingredients":[]}"#
        let data = Data(json.utf8)
        return try JSONDecoder().decode(Cocktail.self, from: data)
    }

    private func catalog(_ cocktails: Cocktail...) -> BundledCocktailCatalog {
        BundledCocktailCatalog(cocktails: cocktails, histories: [], procedures: [])
    }

    private func url(_ id: String) -> URL {
        CocktailClipLink.url(for: id)
    }

    @Test func bundledHitShowsImmediatelyAndKeepsItWhenRemoteMatches() async throws {
        let alpha = try cocktail("a")
        let gate = FetchGate()
        let model = ClipModel(bundled: catalog(alpha), fetchRemote: { await gate.fetch() })
        let opening = Task { await model.open(url("a")) }
        for await _ in gate.started { break }
        #expect(model.content == .cocktail(try #require(ClipCocktail(id: "a", in: catalog(alpha)))))
        await gate.release(catalog(alpha))
        await opening.value
        #expect(model.content == .cocktail(try #require(ClipCocktail(id: "a", in: catalog(alpha)))))
    }

    @Test func bundledHitIsReplacedWhenRemoteDiffers() async throws {
        let updated = catalog(try cocktail("a", name: "Updated"))
        let model = ClipModel(bundled: catalog(try cocktail("a")), fetchRemote: { updated })
        await model.open(url("a"))
        guard case .cocktail(let shown) = model.content else {
            Issue.record("Expected a cocktail")
            return
        }
        #expect(shown.cocktail.name == "Updated")
    }

    @Test func bundledHitStaysWhenRemoteFails() async throws {
        let alpha = try cocktail("a")
        let model = ClipModel(bundled: catalog(alpha), fetchRemote: { nil })
        await model.open(url("a"))
        #expect(model.content == .cocktail(try #require(ClipCocktail(id: "a", in: catalog(alpha)))))
    }

    @Test func unbundledIdLoadsThenShowsRemoteCocktail() async throws {
        let gate = FetchGate()
        let model = ClipModel(bundled: catalog(try cocktail("a")), fetchRemote: { await gate.fetch() })
        let opening = Task { await model.open(url("b")) }
        for await _ in gate.started { break }
        #expect(model.content == .loading)
        let remote = catalog(try cocktail("b"))
        await gate.release(remote)
        await opening.value
        #expect(model.content == .cocktail(try #require(ClipCocktail(id: "b", in: remote))))
    }

    @Test func unbundledIdMissingWhenRemoteFails() async throws {
        let model = ClipModel(bundled: catalog(try cocktail("a")), fetchRemote: { nil })
        await model.open(url("b"))
        #expect(model.content == .missing)
    }

    @Test func unbundledIdMissingWhenRemoteLacksIt() async throws {
        let other = catalog(try cocktail("c"))
        let model = ClipModel(bundled: catalog(try cocktail("a")), fetchRemote: { other })
        await model.open(url("b"))
        #expect(model.content == .missing)
    }

    @Test func waitingTimerDoesNotOverrideLoading() async throws {
        let gate = FetchGate()
        let model = ClipModel(bundled: catalog(try cocktail("a")), fetchRemote: { await gate.fetch() })
        let opening = Task { await model.open(url("b")) }
        for await _ in gate.started { break }
        model.showMissingIfStillWaiting()
        #expect(model.content == .loading)
        await gate.release(nil)
        await opening.value
    }

    @Test func unparseableURLIsMissing() async throws {
        let model = ClipModel(bundled: catalog(try cocktail("a")), fetchRemote: { nil })
        await model.open(URL(string: "https://example.com/nothing")!)
        #expect(model.content == .missing)
    }

    @Test func secondLinkWhileFirstFetchInFlightShowsSecond() async throws {
        let alpha = try cocktail("a")
        let beta = try cocktail("b")
        let gate = FetchGate()
        let bundled = catalog(alpha, beta)
        let model = ClipModel(bundled: bundled, fetchRemote: { await gate.fetch() })
        let first = Task { await model.open(url("a")) }
        for await _ in gate.started { break }
        let second = Task { await model.open(url("b")) }
        for await _ in gate.started { break }
        #expect(model.content == .cocktail(try #require(ClipCocktail(id: "b", in: bundled))))
        // Release both with a catalog where A differs; B must still be shown.
        await gate.release(catalog(try cocktail("a", name: "Updated"), beta))
        await first.value
        await second.value
        #expect(model.content == .cocktail(try #require(ClipCocktail(id: "b", in: bundled))))
    }
}
