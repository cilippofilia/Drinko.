//
//  ReadOnlyContentLoaderTests.swift
//  DrinkoProTests
//

import Foundation
import Testing
@testable import DrinkoPro

struct ReadOnlyContentLoaderTests {
    private let language = "en"
    private let file = ContentFile.cocktails
    private let valid = Data(#"[{"id":"a","name":"A","method":"Stir","glass":"Coupe","garnish":"Lime","ice":"None","extra":"","ingredients":[]}]"#.utf8)

    private func makeCache() -> ContentCache {
        ContentCache(root: URL.temporaryDirectory.appending(path: "ReadOnlyContentLoaderTests-\(UUID().uuidString)"))
    }

    @Test func prefersValidCacheWithoutFetching() async throws {
        let cache = makeCache()
        try cache.commit(files: [file: valid], etags: [:], language: language, checkedAt: .now)
        let fetcher = FakeContentFetcher()
        let loader = ReadOnlyContentLoader(cache: cache, fetcher: fetcher, language: language)
        #expect(await loader.validData(for: file) == valid)
        #expect(fetcher.requests.isEmpty)
    }

    @Test func invalidCacheFallsBackToNetworkAndIsNotDeleted() async throws {
        let cache = makeCache()
        let empty = Data("[]".utf8)
        try cache.commit(files: [file: empty], etags: [:], language: language, checkedAt: .now)
        let fetcher = FakeContentFetcher()
        fetcher.script(file.remotePath(language: language), .success(.modified(valid, etag: nil)))
        let loader = ReadOnlyContentLoader(cache: cache, fetcher: fetcher, language: language)
        #expect(await loader.validData(for: file) == valid)
        #expect(cache.data(for: file, language: language) == empty)
    }

    @Test func missingCacheFetchesWithoutETag() async {
        let fetcher = FakeContentFetcher()
        fetcher.script(file.remotePath(language: language), .success(.modified(valid, etag: "\"e\"")))
        let loader = ReadOnlyContentLoader(cache: makeCache(), fetcher: fetcher, language: language)
        #expect(await loader.validData(for: file) == valid)
        #expect(fetcher.requests.count == 1)
        #expect(fetcher.requests.first?.etag == nil)
    }

    @Test func invalidNetworkDataReturnsNil() async {
        let fetcher = FakeContentFetcher()
        fetcher.script(file.remotePath(language: language), .success(.modified(Data("[]".utf8), etag: nil)))
        let loader = ReadOnlyContentLoader(cache: nil, fetcher: fetcher, language: language)
        #expect(await loader.validData(for: file) == nil)
    }

    @Test func networkFailureReturnsNil() async {
        let fetcher = FakeContentFetcher()
        fetcher.script(file.remotePath(language: language), .failure(ContentFetchError.badStatus(500)))
        let loader = ReadOnlyContentLoader(cache: nil, fetcher: fetcher, language: language)
        #expect(await loader.validData(for: file) == nil)
    }

    @Test func notModifiedReturnsNil() async {
        let fetcher = FakeContentFetcher()
        fetcher.script(file.remotePath(language: language), .success(.notModified))
        let loader = ReadOnlyContentLoader(cache: nil, fetcher: fetcher, language: language)
        #expect(await loader.validData(for: file) == nil)
    }

    @Test func nilFetcherNeverFetches() async {
        let loader = ReadOnlyContentLoader(cache: nil, fetcher: nil, language: language)
        #expect(await loader.validData(for: file) == nil)
    }
}
