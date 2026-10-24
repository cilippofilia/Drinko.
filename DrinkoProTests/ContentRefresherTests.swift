//
//  ContentRefresherTests.swift
//  DrinkoPro
//

import Foundation
import Testing
@testable import DrinkoPro

struct ContentRefresherTests {
    private let language = "en"
    private let now = Date(timeIntervalSince1970: 2_000_000_000)
    private let day: TimeInterval = 24 * 60 * 60

    private let topic = LearnTopic(id: "alpha", title: "Alpha", symbol: "book")

    private func makeCache() -> ContentCache {
        ContentCache(root: URL.temporaryDirectory.appending(path: "ContentRefresherTests-\(UUID().uuidString)"))
    }

    private func json<T: Encodable>(_ value: T) -> Data {
        // Sorted keys keep the bytes identical between calls, so payloads can be compared.
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        return (try? encoder.encode(value)) ?? Data()
    }

    /// Small valid payloads, distinguished by `tag` so old and new content can be told apart.
    private func payload(for file: ContentFile, tag: String = "old") -> Data {
        switch file {
        case .cocktails, .shots:
            json([Cocktail(id: tag, name: "Name", method: "stir", glass: "coupe", garnish: "none", ice: "none",
                           extra: "", ingredients: [Ingredient(name: "Gin", quantity: 2, unit: "oz.")])])
        case .history:
            json([History(id: tag, text: "Text")])
        case .procedure:
            json([Procedure(id: tag, procedure: [Procedure.Steps(step: "1", text: "Do")])])
        case .books:
            json([Book(id: tag, title: "T", description: "D", summary: "S", author: "A")])
        case .topics:
            json([topic])
        default:
            json([Lesson(id: tag, title: "T", description: "D", body: [LessonContent(heading: "H", content: "C")])])
        }
    }

    private var allFiles: [ContentFile] { ContentFile.fixedFiles + [.topic(topic.id)] }

    /// A cache holding every expected file, checked `age` seconds before `now`.
    private func seededCache(age: TimeInterval = 0) throws -> ContentCache {
        let cache = makeCache()
        var files: [ContentFile: Data] = [:]
        for file in allFiles { files[file] = payload(for: file) }
        try cache.commit(files: files, etags: [:], language: language, checkedAt: now.addingTimeInterval(-age))
        return cache
    }

    private func refresher(_ fetcher: FakeContentFetcher, _ cache: ContentCache) -> ContentRefresher {
        let date = now
        return ContentRefresher(fetcher: fetcher, cache: cache, now: { date })
    }

    private func path(_ file: ContentFile) -> String { file.remotePath(language: language) }

    /// Answers 304 for every expected file.
    private func scriptAllNotModified(_ fetcher: FakeContentFetcher) {
        for file in allFiles { fetcher.script(path(file), .success(.notModified)) }
    }

    @Test func freshCacheNeedsNoRefresh() throws {
        let fetcher = FakeContentFetcher()
        let sixDays = try seededCache(age: 6 * day)
        #expect(!refresher(fetcher, sixDays).needsRefresh(language: language))
        let sevenDays = try seededCache(age: 7 * day)
        #expect(refresher(fetcher, sevenDays).needsRefresh(language: language))
    }

    @Test func neverCheckedNeedsRefresh() {
        #expect(refresher(FakeContentFetcher(), makeCache()).needsRefresh(language: language))
    }

    @Test func missingFileNeedsRefresh() throws {
        let cache = try seededCache()
        cache.remove(.topic(topic.id), language: language)
        #expect(refresher(FakeContentFetcher(), cache).needsRefresh(language: language))
        let other = try seededCache()
        other.remove(.books, language: language)
        #expect(refresher(FakeContentFetcher(), other).needsRefresh(language: language))
    }

    @Test func allNotModifiedIsUnchangedAndResetsClock() async throws {
        let cache = try seededCache(age: 8 * day)
        let fetcher = FakeContentFetcher()
        scriptAllNotModified(fetcher)

        let outcome = await refresher(fetcher, cache).refresh(language: language)

        #expect(outcome == .unchanged)
        #expect(cache.metadata().lastSuccessfulCheck[language] == now)
    }

    @Test func oneModifiedFileIsCommittedAlone() async throws {
        let cache = try seededCache(age: 8 * day)
        let fetcher = FakeContentFetcher()
        scriptAllNotModified(fetcher)
        let newProcedure = payload(for: .procedure, tag: "new")
        fetcher.script(path(.procedure), .success(.modified(newProcedure, etag: "\"p2\"")))

        let outcome = await refresher(fetcher, cache).refresh(language: language)

        #expect(outcome == .updated)
        #expect(cache.data(for: .procedure, language: language) == newProcedure)
        #expect(cache.data(for: .books, language: language) == payload(for: .books))
        #expect(cache.metadata().etags == [path(.procedure): "\"p2\""])
    }

    @Test func invalidDownloadRejectsWholeRefresh() async throws {
        let cache = try seededCache(age: 8 * day)
        let before = cache.metadata()
        let fetcher = FakeContentFetcher()
        scriptAllNotModified(fetcher)
        fetcher.script(path(.cocktails), .success(.modified(Data("{".utf8), etag: nil)))
        fetcher.script(path(.history), .success(.modified(payload(for: .history, tag: "new"), etag: "h")))

        let outcome = await refresher(fetcher, cache).refresh(language: language)

        #expect(outcome == .failed)
        #expect(cache.data(for: .cocktails, language: language) == payload(for: .cocktails))
        #expect(cache.data(for: .history, language: language) == payload(for: .history))
        #expect(cache.metadata() == before)
    }

    @Test func emptyArrayDownloadRejected() async throws {
        let cache = try seededCache(age: 8 * day)
        let before = cache.metadata()
        let fetcher = FakeContentFetcher()
        scriptAllNotModified(fetcher)
        fetcher.script(path(.shots), .success(.modified(Data("[]".utf8), etag: nil)))

        #expect(await refresher(fetcher, cache).refresh(language: language) == .failed)
        #expect(cache.metadata() == before)
        #expect(cache.data(for: .shots, language: language) == payload(for: .shots))
    }

    @Test func networkErrorRejectsWholeRefresh() async throws {
        let cache = try seededCache(age: 8 * day)
        let before = cache.metadata()
        let fetcher = FakeContentFetcher()
        scriptAllNotModified(fetcher)
        fetcher.script(path(.books), .failure(URLError(.notConnectedToInternet)))
        fetcher.script(path(.procedure), .success(.modified(payload(for: .procedure, tag: "new"), etag: "p")))

        #expect(await refresher(fetcher, cache).refresh(language: language) == .failed)
        #expect(cache.metadata() == before)
        #expect(cache.data(for: .procedure, language: language) == payload(for: .procedure))
    }

    @Test func topicsFailureSkipsPhaseTwo() async throws {
        let cache = try seededCache(age: 8 * day)
        let fetcher = FakeContentFetcher()
        fetcher.script(path(.topics), .failure(URLError(.timedOut)))

        #expect(await refresher(fetcher, cache).refresh(language: language) == .failed)
        #expect(fetcher.requests.map(\.path) == [path(.topics)])
    }

    @Test func manifestListingMissingTopicRejectsWholeRefresh() async throws {
        let cache = try seededCache(age: 8 * day)
        let before = cache.metadata()
        let oldManifest = cache.data(for: .topics, language: language)
        let fetcher = FakeContentFetcher()
        scriptAllNotModified(fetcher)
        let newManifest = json([topic, LearnTopic(id: "new-topic", title: "New", symbol: "star")])
        fetcher.script(path(.topics), .success(.modified(newManifest, etag: "m")))
        fetcher.script(path(.topic("new-topic")), .failure(ContentFetchError.badStatus(404)))

        #expect(await refresher(fetcher, cache).refresh(language: language) == .failed)
        #expect(cache.data(for: .topics, language: language) == oldManifest)
        #expect(cache.metadata() == before)
    }

    @Test func newTopicFromManifestIsFetchedAndCommitted() async throws {
        let cache = try seededCache(age: 8 * day)
        let fetcher = FakeContentFetcher()
        scriptAllNotModified(fetcher)
        let newManifest = json([topic, LearnTopic(id: "new-topic", title: "New", symbol: "star")])
        fetcher.script(path(.topics), .success(.modified(newManifest, etag: "m")))
        fetcher.script(path(.topic("new-topic")),
                       .success(.modified(payload(for: .topic("new-topic")), etag: nil)))

        #expect(await refresher(fetcher, cache).refresh(language: language) == .updated)
        #expect(cache.data(for: .topic("new-topic"), language: language) != nil)
        #expect(cache.data(for: .topics, language: language) == newManifest)
    }

    @Test func etagWithoutCachedFileIsNotSent() async throws {
        let cache = try seededCache(age: 8 * day)
        cache.remove(.books, language: language)
        try cache.commit(files: [:], etags: [path(.books): "stale"], language: language,
                         checkedAt: now.addingTimeInterval(-8 * day))
        let fetcher = FakeContentFetcher()
        scriptAllNotModified(fetcher)
        fetcher.script(path(.books), .success(.modified(payload(for: .books), etag: "fresh")))

        #expect(await refresher(fetcher, cache).refresh(language: language) == .updated)
        let sent = fetcher.requests.first { $0.path == path(.books) }
        #expect(sent != nil)
        #expect(sent?.etag == nil)
    }

    @Test func notModifiedWithoutCachedFileFails() async throws {
        let cache = try seededCache(age: 8 * day)
        cache.remove(.books, language: language)
        let fetcher = FakeContentFetcher()
        scriptAllNotModified(fetcher)

        #expect(await refresher(fetcher, cache).refresh(language: language) == .failed)
    }

    @Test func storedETagIsSentVerbatim() async throws {
        let cache = try seededCache(age: 8 * day)
        try cache.commit(files: [:], etags: [path(.history): "W/\"abc\""], language: language,
                         checkedAt: now.addingTimeInterval(-8 * day))
        let fetcher = FakeContentFetcher()
        scriptAllNotModified(fetcher)

        _ = await refresher(fetcher, cache).refresh(language: language)

        #expect(fetcher.requests.first { $0.path == path(.history) }?.etag == "W/\"abc\"")
    }
}
