//
//  ContentCacheMigrationTests.swift
//  DrinkoPro
//

import Foundation
import Testing
@testable import DrinkoPro

struct ContentCacheMigrationTests {
    private func makeBase() -> URL {
        URL.temporaryDirectory.appending(path: "ContentCacheMigrationTests-\(UUID().uuidString)")
    }

    private func write(_ text: String, to directory: URL) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try Data(text.utf8).write(to: directory.appending(path: "metadata.json"))
    }

    private func read(_ directory: URL) -> String? {
        guard let data = try? Data(contentsOf: directory.appending(path: "metadata.json")) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func exists(_ url: URL) -> Bool {
        FileManager.default.fileExists(atPath: url.path(percentEncoded: false))
    }

    @Test func movesLegacyCacheWhenSharedIsMissing() throws {
        let base = makeBase()
        let legacy = base.appending(path: "legacy")
        let shared = base.appending(path: "group/RemoteContent")
        try write("legacy", to: legacy)

        ContentCacheMigration.run(from: legacy, to: shared)

        #expect(read(shared) == "legacy")
        #expect(!exists(legacy))
    }

    @Test func keepsExistingSharedCacheAndDeletesLegacy() throws {
        let base = makeBase()
        let legacy = base.appending(path: "legacy")
        let shared = base.appending(path: "shared")
        try write("legacy", to: legacy)
        try write("shared", to: shared)

        ContentCacheMigration.run(from: legacy, to: shared)

        #expect(read(shared) == "shared")
        #expect(!exists(legacy))
    }

    @Test func doesNothingWithoutLegacyCache() {
        let base = makeBase()
        let shared = base.appending(path: "shared")

        ContentCacheMigration.run(from: base.appending(path: "legacy"), to: shared)

        #expect(!exists(shared))
    }

    @Test func doesNothingWhenPathsAreEqual() throws {
        let directory = makeBase().appending(path: "same")
        try write("kept", to: directory)

        ContentCacheMigration.run(from: directory, to: directory)

        #expect(read(directory) == "kept")
    }
}
