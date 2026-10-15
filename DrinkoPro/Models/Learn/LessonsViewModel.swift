//
//  LessonsViewModel.swift
//  DrinkoPro
//

import Foundation
import Observation

@MainActor
@Observable
class LessonsViewModel {
    let topics: [LearnTopic]
    private(set) var lessonsByTopic: [String: [Lesson]]
    var books: [Book] = Bundle.main.decode([Book].self, from: "books.json")

    /// Cached id → item lookup, built lazily since lessons and books are bundled and don't
    /// change after init. See `LessonsViewModel+Library.recentItems(from:)`.
    @ObservationIgnored var itemsByIDCache: [String: LearnView.Selection]?

    init(topics: [LearnTopic] = LearnTopic.all) {
        self.topics = topics
        var lessons: [String: [Lesson]] = [:]
        for topic in topics {
            lessons[topic.id] = Bundle.main.decode([Lesson].self, from: "\(topic.id).json")
        }
        lessonsByTopic = lessons
    }

    /// Every lesson, in topic manifest order.
    var allLessons: [Lesson] {
        topics.flatMap { lessons(for: $0.id) }
    }

    func lessons(for topicID: String) -> [Lesson] {
        lessonsByTopic[topicID] ?? []
    }

    /// Returns the lessons for `topicID` whose title or description match `query`.
    ///
    /// Whitespace is trimmed from `query`; an empty (or whitespace-only) query returns every
    /// lesson for that topic unfiltered.
    func filteredLessons(for topicID: String, matching query: String) -> [Lesson] {
        let lessons = lessons(for: topicID)
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return lessons }

        return lessons.filter { lesson in
            lesson.title.localizedStandardContains(trimmedQuery) ||
            lesson.description.localizedStandardContains(trimmedQuery)
        }
    }

    /// Returns the books whose title, description or author match `query`.
    ///
    /// Whitespace is trimmed from `query`; an empty (or whitespace-only) query returns every book
    /// unfiltered.
    func filteredBooks(matching query: String) -> [Book] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return books }

        return books.filter { book in
            book.title.localizedStandardContains(trimmedQuery) ||
            book.description.localizedStandardContains(trimmedQuery) ||
            book.author.localizedStandardContains(trimmedQuery)
        }
    }

    /// Whether any lesson (across all topics) or book matches `query`.
    ///
    /// An empty (or whitespace-only) query always returns `true`.
    func hasResults(matching query: String) -> Bool {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return true }

        if !filteredBooks(matching: query).isEmpty {
            return true
        }

        return topics.contains { !filteredLessons(for: $0.id, matching: query).isEmpty }
    }
}
