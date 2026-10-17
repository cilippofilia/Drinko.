//
//  LessonsViewModel+Library.swift
//  DrinkoPro
//

import Foundation
import SwiftUI

extension LessonsViewModel {
    nonisolated static let booksSectionID = "books"

    /// Every library section ID in display order: the topics, then Books.
    nonisolated static var librarySectionIDs: [String] {
        LearnTopic.all.map(\.id) + [booksSectionID]
    }

    nonisolated static func sectionTitle(for id: String) -> String? {
        if id == booksSectionID {
            return String(localized: "Books")
        }
        return LearnTopic.all.first { $0.id == id }?.title
    }

    nonisolated static func sidebarSymbol(for id: String) -> String {
        switch id {
        case "basic-lessons": "graduationcap"
        case "bar-preps": "list.bullet.clipboard"
        case "basic-spirits": "waterbottle"
        case "advanced-spirits": "star"
        case "liqueurs": "drop.halffull"
        case "advanced-lessons": "brain.head.profile"
        case "syrups": "flask"
        case booksSectionID: "books.vertical"
        default: "book"
        }
    }

    var allItems: [LearnView.Selection] {
        allLessons.map { .lesson($0) } + books.map { .book($0) }
    }

    /// Topic sections in manifest order, then Books. A non-empty `query` filters every section
    /// and drops the ones left empty.
    func librarySections(matching query: String) -> [LibrarySection<LearnView.Selection>] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        var sections = topics.map { topic in
            LibrarySection(
                id: topic.id,
                title: topic.title,
                items: filteredLessons(for: topic.id, matching: trimmedQuery).map { LearnView.Selection.lesson($0) }
            )
        }

        sections.append(
            LibrarySection(
                id: Self.booksSectionID,
                title: String(localized: "Books"),
                items: filteredBooks(matching: trimmedQuery).map { LearnView.Selection.book($0) }
            )
        )

        return sections.filter { !$0.items.isEmpty }
    }

    func cardModel(for item: LearnView.Selection) -> LibraryCardModel {
        switch item {
        case .lesson(let lesson):
            LibraryCardModel(
                title: lesson.title,
                subtitle: lesson.description,
                image: .remote(URL(string: lesson.image))
            )
        case .book(let book):
            LibraryCardModel(
                title: book.title,
                subtitle: "© \(book.author)",
                image: .remote(URL(string: book.image)),
                // The cover already shows the title.
                showsCardTitle: false
            )
        }
    }

    /// Maps stored recent IDs back to items, keeping order and dropping IDs that no longer exist.
    func recentItems(from ids: [String]) -> [LearnView.Selection] {
        ids.compactMap { itemsByID[$0] }
    }

    private var itemsByID: [String: LearnView.Selection] {
        if let cached = itemsByIDCache {
            return cached
        }
        let dict = Dictionary(allItems.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        itemsByIDCache = dict
        return dict
    }
}
