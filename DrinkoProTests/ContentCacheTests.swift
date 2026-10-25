//
//  ContentCacheTests.swift
//  DrinkoPro
//

import Foundation
import Testing
@testable import DrinkoPro

struct ContentCacheTests {
    private func makeCache() -> ContentCache {
        ContentCache(root: URL.temporaryDirectory.appending(path: "ContentCacheTests-\(UUID().uuidString)"))
    }

    @Test func rootUsesSharedContainerWhenAvailable() {
        let container = URL.temporaryDirectory.appending(path: "group")
        #expect(ContentCache.root(sharedContainer: container) == container.appending(path: "RemoteContent"))
    }

    @Test func rootFallsBackToApplicationSupport() {
        #expect(ContentCache.root(sharedContainer: nil) == ContentCache.legacyRoot)
    }

    @Test func missingFileReturnsNil() {
        let cache = makeCache()
        #expect(cache.data(for: .books, language: "en") == nil)
        #expect(cache.metadata() == ContentCacheMetadata())
    }

    @Test func commitWritesFilesETagsAndCheckDate() throws {
        let cache = makeCache()
        let date = Date(timeIntervalSince1970: 1_000_000)
        let payload = Data("hello".utf8)
        let path = ContentFile.books.cacheKey(language: "en")

        try cache.commit(files: [.books: payload], etags: [path: "abc"], language: "en", checkedAt: date)

        #expect(cache.data(for: .books, language: "en") == payload)
        #expect(cache.metadata().etags[path] == "abc")
        #expect(cache.metadata().lastSuccessfulCheck["en"] == date)

        cache.remove(.books, language: "en")
        #expect(cache.data(for: .books, language: "en") == nil)
    }

    @Test func commitMergesMetadata() throws {
        let cache = makeCache()
        let enDate = Date(timeIntervalSince1970: 1_000)
        let deDate = Date(timeIntervalSince1970: 2_000)

        try cache.commit(files: [.books: Data("a".utf8)], etags: ["books/en/books.json": "e1", "x": "keep"],
                         language: "en", checkedAt: enDate)
        try cache.commit(files: [.books: Data("b".utf8)], etags: ["books/de/books.json": "d1"],
                         language: "de", checkedAt: deDate)

        let metadata = cache.metadata()
        #expect(metadata.lastSuccessfulCheck["en"] == enDate)
        #expect(metadata.lastSuccessfulCheck["de"] == deDate)
        #expect(metadata.etags["x"] == "keep")
        #expect(metadata.etags["books/en/books.json"] == "e1")
        #expect(metadata.etags["books/de/books.json"] == "d1")
    }

    @Test func localizedFilesAreSeparatedByLanguage() throws {
        let cache = makeCache()
        try cache.commit(files: [.shots: Data("s".utf8), .cocktails: Data("c".utf8)], etags: [:],
                         language: "en", checkedAt: .now)

        #expect(cache.data(for: .shots, language: "de") == nil)
        #expect(cache.data(for: .shots, language: "en") != nil)
        #expect(cache.data(for: .cocktails, language: "de") == Data("c".utf8))
    }

    @Test func rootIsExcludedFromBackup() throws {
        let root = URL.temporaryDirectory.appending(path: "ContentCacheTests-backup-\(UUID().uuidString)")
        let backupCache = ContentCache(root: root)
        try backupCache.commit(files: [.books: Data("a".utf8)], etags: [:], language: "en", checkedAt: .now)

        let values = try root.resourceValues(forKeys: [.isExcludedFromBackupKey])
        #expect(values.isExcludedFromBackup == true)
    }
}
