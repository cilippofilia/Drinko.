//
//  Lesson.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 27/04/2023.
//

import SwiftUI

struct Lesson: Codable, Equatable, Identifiable, Hashable {
    let id: String
    var title: String
    var description: String
    var body: [LessonContent]
    
    var hasVideo: Bool?
    var videoURL: String?
    var videoID: String?

    var image: String {
        "https://raw.githubusercontent.com/cilippofilia/drinko-learn-pics/main/\(id).jpg"
    }
}

struct LessonContent: Codable, Equatable, Identifiable, Hashable {
    var id: String { heading }
    let heading: String
    let content: String
}

@MainActor
@Observable
class LessonsViewModel {
    var basicLessons: [Lesson] = Bundle.main.decode([Lesson].self, from: "basic-lessons.json")
    var advancedLessons: [Lesson] = Bundle.main.decode([Lesson].self, from: "advanced-lessons.json")
    var barPreps: [Lesson] = Bundle.main.decode([Lesson].self, from: "bar-preps.json")
    var basicSpirits: [Lesson] = Bundle.main.decode([Lesson].self, from: "basic-spirits.json")
    var advancedSpirits: [Lesson] = Bundle.main.decode([Lesson].self, from: "advanced-spirits.json")
    var liqueurs: [Lesson] = Bundle.main.decode([Lesson].self, from: "liqueurs.json")
    var books: [Book] = Bundle.main.decode([Book].self, from: "books.json")
    var syrups: [Lesson] = Bundle.main.decode([Lesson].self, from: "syrups.json")

    init() { }

    let topics = [
        "basic-lessons",
        "bar-preps",
        "basic-spirits",
        "advanced-spirits",
        "liqueurs",
        "advanced-lessons",
        "syrups"
    ]

    var allLessons: [Lesson] {
        return basicLessons + advancedLessons + barPreps + basicSpirits + advancedSpirits + liqueurs + syrups
    }

    func getLessons(for topic: String) -> [Lesson] {
        switch topic {
        case "basic-lessons":
            return basicLessons
        case "advanced-lessons":
            return advancedLessons
        case "bar-preps":
            return barPreps
        case "basic-spirits":
            return basicSpirits
        case "advanced-spirits":
            return advancedSpirits
        case "liqueurs":
            return liqueurs
        case "syrups":
            return syrups
        default:
            return []
        }
    }

    /// Returns the lessons for `topic` whose title or description match `query`.
    ///
    /// Whitespace is trimmed from `query`; an empty (or whitespace-only) query returns every
    /// lesson for that topic unfiltered.
    func filteredLessons(for topic: String, matching query: String) -> [Lesson] {
        let lessons = getLessons(for: topic)
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

        return topics.contains { !filteredLessons(for: $0, matching: query).isEmpty }
    }
}
