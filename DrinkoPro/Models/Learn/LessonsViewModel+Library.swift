//
//  LessonsViewModel+Library.swift
//  DrinkoPro
//

import Foundation
import SwiftUI

extension LessonsViewModel {
    static let booksSectionID = "books"

    /// Every item the Learn library can show.
    var allItems: [LearnView.Selection] {
        allLessons.map { .lesson($0) } + books.map { .book($0) }
    }

    /// Topic sections in manifest order, then Books.
    ///
    /// A non-empty (trimmed) `query` filters every section and drops the ones left empty.
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

    /// Display data for one Learn item.
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
    ///
    /// Looks up items in the cached id → item dictionary, built once on first use since lessons
    /// and books are bundled and don't change after init.
    func recentItems(from ids: [String]) -> [LearnView.Selection] {
        ids.compactMap { itemsByID[$0] }
    }

    /// The id → item lookup, built once on first use.
    private var itemsByID: [String: LearnView.Selection] {
        if let cached = itemsByIDCache {
            return cached
        }
        let dict = Dictionary(allItems.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        itemsByIDCache = dict
        return dict
    }
}
