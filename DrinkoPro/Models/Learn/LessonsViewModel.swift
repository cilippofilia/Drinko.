//
//  LessonsViewModel.swift
//  DrinkoPro
//

import Foundation
import Observation

@MainActor
@Observable
class LessonsViewModel {
    private(set) var topics: [LearnTopic]
    private(set) var lessonsByTopic: [String: [Lesson]]
    var books: [Book] = Bundle.main.decode([Book].self, from: "books.json")

    /// Built on first use; lessons and books are bundled and never change.
    @ObservationIgnored var itemsByIDCache: [String: LearnView.Selection]?

    init(topics: [LearnTopic] = LearnTopic.bundled) {
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

    /// The lessons for `topicID` whose title or description match `query`, or all of them for a
    /// blank query.
    func filteredLessons(for topicID: String, matching query: String) -> [Lesson] {
        let lessons = lessons(for: topicID)
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return lessons }

        return lessons.filter { lesson in
            lesson.title.localizedStandardContains(trimmedQuery) ||
            lesson.description.localizedStandardContains(trimmedQuery)
        }
    }

    /// The books whose title, description or author match `query`, or all of them for a blank query.
    func filteredBooks(matching query: String) -> [Book] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return books }

        return books.filter { book in
            book.title.localizedStandardContains(trimmedQuery) ||
            book.description.localizedStandardContains(trimmedQuery) ||
            book.author.localizedStandardContains(trimmedQuery)
        }
    }

    /// Whether any lesson or book matches `query`. Always `true` for a blank query.
    func hasResults(matching query: String) -> Bool {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return true }

        if !filteredBooks(matching: query).isEmpty {
            return true
        }

        return topics.contains { !filteredLessons(for: $0.id, matching: query).isEmpty }
    }
}
