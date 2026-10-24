//
//  ContentSnapshotTests.swift
//  DrinkoPro
//

import Foundation
import Testing
@testable import DrinkoPro

struct ContentSnapshotTests {
    private func makeCache() -> ContentCache {
        ContentCache(root: URL.temporaryDirectory.appending(path: "ContentSnapshotTests-\(UUID().uuidString)"))
    }

    private func store(_ data: Data, as file: ContentFile, language: String = "en", in cache: ContentCache) throws {
        try cache.commit(files: [file: data], etags: [:], language: language, checkedAt: .now)
    }

    private func store<T: Encodable>(
        _ value: T, as file: ContentFile, language: String = "en", in cache: ContentCache
    ) throws {
        try store(JSONEncoder().encode(value), as: file, language: language, in: cache)
    }

    private func cocktail(id: String) -> Cocktail {
        Cocktail(id: id, name: "Name", method: "stir", glass: "coupe", garnish: "none", ice: "none",
                 extra: "", ingredients: [Ingredient(name: "Gin", quantity: 2, unit: "oz.")])
    }

    private func lesson(id: String) -> Lesson {
        Lesson(id: id, title: "Title", description: "Description",
               body: [LessonContent(heading: "H", content: "C")])
    }

    @Test func emptyCacheEqualsBundled() {
        #expect(ContentSnapshot.load(cache: makeCache(), language: "en") == ContentSnapshot.bundled())
    }

    @Test func cachedFileWinsOverBundle() throws {
        let cache = makeCache()
        try store([cocktail(id: "only-one")], as: .cocktails, in: cache)

        let snapshot = ContentSnapshot.load(cache: cache, language: "en")

        #expect(snapshot.cocktails.map(\.id) == ["only-one"])
        #expect(snapshot.shots == ContentSnapshot.bundled().shots)
    }

    @Test func corruptCachedFileFallsBackToBundleAndIsRemoved() throws {
        let cache = makeCache()
        try store(Data("{".utf8), as: .history, in: cache)

        let snapshot = ContentSnapshot.load(cache: cache, language: "en")

        #expect(snapshot.histories == ContentSnapshot.bundled().histories)
        #expect(cache.data(for: .history, language: "en") == nil)
    }

    @Test func otherLanguagesCacheIsIgnored() throws {
        let cache = makeCache()
        try store([cocktail(id: "german")], as: .shots, language: "de", in: cache)

        #expect(ContentSnapshot.load(cache: cache, language: "it").shots == ContentSnapshot.bundled().shots)
    }

    @Test func cachedManifestDrivesTopics() throws {
        let cache = makeCache()
        let topics = [
            LearnTopic(id: "basic-lessons", title: "Basics", symbol: "book"),
            LearnTopic(id: "new-topic", title: "New", symbol: "star")
        ]
        try store(topics, as: .topics, in: cache)
        try store([lesson(id: "fresh")], as: .topic("new-topic"), in: cache)

        let snapshot = ContentSnapshot.load(cache: cache, language: "en")

        #expect(snapshot.topics.map(\.id) == ["basic-lessons", "new-topic"])
        #expect(snapshot.lessonsByTopic["new-topic"]?.map(\.id) == ["fresh"])
    }

    @Test func topicWithNoLessonsIsDropped() throws {
        let cache = makeCache()
        try store([LearnTopic(id: "ghost", title: "Ghost", symbol: "book")], as: .topics, in: cache)

        let snapshot = ContentSnapshot.load(cache: cache, language: "en")

        #expect(!snapshot.topics.map(\.id).contains("ghost"))
        #expect(snapshot.lessonsByTopic["ghost"] == nil)
    }

    @Test func unsafeCachedManifestFallsBackToBundleAndIsRemoved() throws {
        let cache = makeCache()
        try store([LearnTopic(id: "../x", title: "Bad", symbol: "book")], as: .topics, in: cache)

        let snapshot = ContentSnapshot.load(cache: cache, language: "en")

        #expect(snapshot.topics == ContentSnapshot.bundled().topics)
        #expect(cache.data(for: .topics, language: "en") == nil)
    }

    @Test func validateRejectsEmptyArray() {
        #expect(throws: ContentDecodingError.self) {
            try ContentDecoding.validate(Data("[]".utf8), as: .cocktails)
        }
    }

    @Test func validateRejectsWrongShape() throws {
        let data = try JSONEncoder().encode([lesson(id: "x")])
        #expect(throws: (any Error).self) {
            try ContentDecoding.validate(data, as: .cocktails)
        }
    }

    @Test func validateAcceptsGoodData() throws {
        let data = try JSONEncoder().encode([cocktail(id: "ok")])
        try ContentDecoding.validate(data, as: .shots)
    }

    @Test func validateRejectsUnsafeTopicID() throws {
        for id in ["../x", "a/b", "A", "-a", "a--b", ""] {
            let data = try JSONEncoder().encode([LearnTopic(id: id, title: "T", symbol: "book")])
            #expect(throws: ContentDecodingError.self) {
                try ContentDecoding.validate(data, as: .topics)
            }
        }
    }

    @Test func validateRejectsDuplicateTopicIDs() throws {
        let topic = LearnTopic(id: "same", title: "T", symbol: "book")
        let data = try JSONEncoder().encode([topic, topic])
        #expect(throws: ContentDecodingError.self) {
            try ContentDecoding.validate(data, as: .topics)
        }
    }

    @Test func validateRejectsEmptyTopicTitle() throws {
        let data = try JSONEncoder().encode([LearnTopic(id: "fine", title: "", symbol: "book")])
        #expect(throws: ContentDecodingError.self) {
            try ContentDecoding.validate(data, as: .topics)
        }
    }
}
