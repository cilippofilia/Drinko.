//
//  ContentStoreTests.swift
//  DrinkoPro
//

import Foundation
import Testing
@testable import DrinkoPro

/// A fetcher that suspends every request until `release()` is called.
private final class GatedFetcher: ContentFetching, @unchecked Sendable {
    let inner = FakeContentFetcher()
    private let lock = NSLock()
    private var isOpen = false
    private var waiters: [CheckedContinuation<Void, Never>] = []

    func release() {
        let pending = lock.withLock { () -> [CheckedContinuation<Void, Never>] in
            isOpen = true
            defer { waiters = [] }
            return waiters
        }
        pending.forEach { $0.resume() }
    }

    func fetch(path: String, etag: String?) async throws -> ContentFetchResult {
        await withCheckedContinuation { continuation in
            let resumeNow = lock.withLock { () -> Bool in
                if isOpen { return true }
                waiters.append(continuation)
                return false
            }
            if resumeNow { continuation.resume() }
        }
        return try await inner.fetch(path: path, etag: etag)
    }
}

@MainActor
struct ContentStoreTests {
    private let language = "en"
    private let support = ContentRefresherTests()

    private var allFiles: [ContentFile] { ContentFile.fixedFiles + [.topic(support.topic.id)] }

    /// A cache holding every expected file, last checked `age` seconds ago.
    private func seededCache(age: TimeInterval) throws -> ContentCache {
        let cache = ContentCache(root: URL.temporaryDirectory.appending(path: "ContentStoreTests-\(UUID().uuidString)"))
        var files: [ContentFile: Data] = [:]
        for file in allFiles { files[file] = support.payload(for: file) }
        try cache.commit(files: files, etags: [:], language: language, checkedAt: Date().addingTimeInterval(-age))
        return cache
    }

    private func scriptNotModified(_ fetcher: FakeContentFetcher) {
        for file in allFiles { fetcher.script(file.remotePath(language: language), .success(.notModified)) }
    }

    private let eightDays: TimeInterval = 8 * 24 * 60 * 60

    @Test func freshCacheMakesNoRequests() async throws {
        let fetcher = FakeContentFetcher()
        let store = ContentStore(cache: try seededCache(age: 0), fetcher: fetcher, language: language)

        let snapshot = await store.refreshIfNeeded()

        #expect(snapshot == nil)
        #expect(fetcher.requests.isEmpty)
    }

    @Test func updatedRefreshReturnsSnapshot() async throws {
        let fetcher = FakeContentFetcher()
        scriptNotModified(fetcher)
        let download = support.payload(for: .cocktails, tag: "new")
        let cocktailsPath = ContentFile.cocktails.remotePath(language: language)
        fetcher.script(cocktailsPath, .success(.modified(download, etag: "\"c2\"")))
        let store = ContentStore(cache: try seededCache(age: eightDays), fetcher: fetcher, language: language)

        let snapshot = await store.refreshIfNeeded()

        #expect(snapshot?.cocktails.map(\.id) == ["new"])
        #expect(snapshot?.shots.map(\.id) == ["old"])
    }

    @Test func unchangedRefreshReturnsNil() async throws {
        let fetcher = FakeContentFetcher()
        scriptNotModified(fetcher)
        let store = ContentStore(cache: try seededCache(age: eightDays), fetcher: fetcher, language: language)

        #expect(await store.refreshIfNeeded() == nil)
    }

    @Test func sourceIsBundledWithoutCache() {
        let cache = ContentCache(root: URL.temporaryDirectory.appending(path: "ContentStoreTests-\(UUID().uuidString)"))
        let store = ContentStore(cache: cache, fetcher: FakeContentFetcher(), language: language)

        _ = store.initialSnapshot()

        #expect(store.source == .bundled)
    }

    @Test func sourceIsCachedWithLastCheckDate() throws {
        let cache = try seededCache(age: 60)
        let checkedAt = try #require(cache.metadata().lastSuccessfulCheck[language])
        let store = ContentStore(cache: cache, fetcher: FakeContentFetcher(), language: language)

        _ = store.initialSnapshot()

        #expect(store.source == .cached(checkedAt: checkedAt))
    }

    @Test func sourceIsFetchedAfterUpdate() async throws {
        let fetcher = FakeContentFetcher()
        scriptNotModified(fetcher)
        fetcher.script(
            ContentFile.cocktails.remotePath(language: language),
            .success(.modified(support.payload(for: .cocktails, tag: "new"), etag: "\"c2\""))
        )
        let store = ContentStore(cache: try seededCache(age: eightDays), fetcher: fetcher, language: language)
        _ = store.initialSnapshot()

        _ = await store.refreshIfNeeded()

        guard case .fetched = store.source else {
            Issue.record("Expected .fetched, got \(store.source)")
            return
        }
    }

    @Test func sourceStaysCachedWithNewCheckDateAfterUnchangedRefresh() async throws {
        let fetcher = FakeContentFetcher()
        scriptNotModified(fetcher)
        let cache = try seededCache(age: eightDays)
        let store = ContentStore(cache: cache, fetcher: fetcher, language: language)
        _ = store.initialSnapshot()

        _ = await store.refreshIfNeeded()

        let checkedAt = try #require(cache.metadata().lastSuccessfulCheck[language])
        #expect(store.source == .cached(checkedAt: checkedAt))
        #expect(Date().timeIntervalSince(checkedAt) < 60)
    }

    @Test func concurrentRefreshesShareOneRun() async throws {
        let fetcher = GatedFetcher()
        scriptNotModified(fetcher.inner)
        fetcher.inner.script(
            ContentFile.cocktails.remotePath(language: language),
            .success(.modified(support.payload(for: .cocktails, tag: "new"), etag: "\"c2\""))
        )
        let store = ContentStore(cache: try seededCache(age: eightDays), fetcher: fetcher, language: language)

        async let first = store.refreshIfNeeded()
        async let second = store.refreshIfNeeded()
        // Let both callers start and the run reach the network before opening the gate.
        for _ in 0..<200 where fetcher.inner.requests.isEmpty {
            try await Task.sleep(for: .milliseconds(10))
        }
        try await Task.sleep(for: .milliseconds(100))
        fetcher.release()
        let (firstResult, secondResult) = await (first, second)

        let paths = fetcher.inner.requests.map(\.path)
        #expect(!paths.isEmpty)
        #expect(paths.count == Set(paths).count)
        #expect(firstResult != nil)
        #expect(firstResult == secondResult)
    }

    /// Counts `onContentUpdated` calls.
    private final class ReloadCounter {
        var count = 0
    }

    @Test func updateReloadsWidgetsOnce() async throws {
        let fetcher = FakeContentFetcher()
        scriptNotModified(fetcher)
        fetcher.script(
            ContentFile.cocktails.remotePath(language: language),
            .success(.modified(support.payload(for: .cocktails, tag: "new"), etag: "\"c2\""))
        )
        let counter = ReloadCounter()
        let store = ContentStore(
            cache: try seededCache(age: eightDays),
            fetcher: fetcher,
            language: language,
            onContentUpdated: { counter.count += 1 }
        )

        _ = await store.refreshIfNeeded()

        #expect(counter.count == 1)
    }

    @Test func unchangedRefreshDoesNotReloadWidgets() async throws {
        let counter = ReloadCounter()
        let store = ContentStore(
            cache: try seededCache(age: 0),
            fetcher: FakeContentFetcher(),
            language: language,
            onContentUpdated: { counter.count += 1 }
        )

        _ = await store.refreshIfNeeded()

        #expect(counter.count == 0)
    }

    @Test func failedRefreshDoesNotReloadWidgets() async throws {
        let counter = ReloadCounter()
        // Unscripted paths answer 404.
        let store = ContentStore(
            cache: try seededCache(age: eightDays),
            fetcher: FakeContentFetcher(),
            language: language,
            onContentUpdated: { counter.count += 1 }
        )

        #expect(await store.refreshIfNeeded() == nil)
        #expect(counter.count == 0)
    }
}
