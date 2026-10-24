//
//  ContentSnapshot.swift
//  DrinkoPro
//

import Foundation

/// All decoded content, loaded from the cache with the app bundle as the fallback.
struct ContentSnapshot: Equatable, Sendable {
    var cocktails: [Cocktail]
    var shots: [Cocktail]
    var histories: [History]
    var procedures: [Procedure]
    var books: [Book]
    var topics: [LearnTopic]
    var lessonsByTopic: [String: [Lesson]]

    /// The content shipped in the app.
    static func bundled(_ bundle: Bundle = .main) -> ContentSnapshot {
        let topics = bundle.decode([LearnTopic].self, from: ContentFile.topics.bundleFileName)
        let lessonsByTopic = lessons(for: topics, bundle: bundle) { _ in nil }
        return ContentSnapshot(
            cocktails: bundle.decode([Cocktail].self, from: ContentFile.cocktails.bundleFileName),
            shots: bundle.decode([Cocktail].self, from: ContentFile.shots.bundleFileName),
            histories: bundle.decode([History].self, from: ContentFile.history.bundleFileName),
            procedures: bundle.decode([Procedure].self, from: ContentFile.procedure.bundleFileName),
            books: bundle.decode([Book].self, from: ContentFile.books.bundleFileName),
            topics: topics.filter { lessonsByTopic[$0.id] != nil },
            lessonsByTopic: lessonsByTopic
        )
    }

    /// Loads each file from the cache when it is valid and from the bundle otherwise.
    ///
    /// A cached file that fails validation is deleted so it isn't tried again. The bundle's copy is
    /// whatever the bundle's current localization resolves to; `language` only selects the cache folder.
    static func load(cache: ContentCache, language: String, bundle: Bundle = .main) -> ContentSnapshot {
        func cached<T: Decodable>(_ file: ContentFile, _ type: T.Type) -> [T]? {
            guard let data = cache.data(for: file, language: language) else { return nil }
            do {
                try ContentDecoding.validate(data, as: file)
                return try JSONDecoder().decode([T].self, from: data)
            } catch {
                cache.remove(file, language: language)
                return nil
            }
        }

        func fixed<T: Decodable>(_ file: ContentFile, _ type: T.Type) -> [T] {
            cached(file, type) ?? bundle.decode([T].self, from: file.bundleFileName)
        }

        let topics = cached(.topics, LearnTopic.self)
            ?? bundle.decode([LearnTopic].self, from: ContentFile.topics.bundleFileName)

        let lessonsByTopic = lessons(for: topics, bundle: bundle) { topic in
            cached(.topic(topic.id), Lesson.self)
        }

        return ContentSnapshot(
            cocktails: fixed(.cocktails, Cocktail.self),
            shots: fixed(.shots, Cocktail.self),
            histories: fixed(.history, History.self),
            procedures: fixed(.procedure, Procedure.self),
            books: fixed(.books, Book.self),
            topics: topics.filter { lessonsByTopic[$0.id] != nil },
            lessonsByTopic: lessonsByTopic
        )
    }

    /// The lessons for each topic from `cached`, then the bundle. Topics without lessons are omitted.
    private static func lessons(
        for topics: [LearnTopic],
        bundle: Bundle,
        cached: (LearnTopic) -> [Lesson]?
    ) -> [String: [Lesson]] {
        var result: [String: [Lesson]] = [:]
        for topic in topics {
            if let lessons = cached(topic) ?? bundledLessons(for: topic, bundle: bundle) {
                result[topic.id] = lessons
            }
        }
        return result
    }

    /// Decodes a bundled topic file only when it exists, because `Bundle.decode` traps on missing files.
    private static func bundledLessons(for topic: LearnTopic, bundle: Bundle) -> [Lesson]? {
        let name = ContentFile.topic(topic.id).bundleFileName
        guard bundle.url(forResource: name, withExtension: nil) != nil else { return nil }
        let lessons = bundle.decode([Lesson].self, from: name)
        return lessons.isEmpty ? nil : lessons
    }
}
