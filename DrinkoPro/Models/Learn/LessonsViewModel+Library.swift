//
//  LessonsViewModel+Library.swift
//  DrinkoPro
//

import Foundation
import SwiftUI

extension LessonsViewModel {
    static let calculatorsSectionID = "calculators"
    static let booksSectionID = "books"
    private static let superjuiceTypes = ["lime", "lemon"]

    /// The calculator entries shown in the Calculators section, in display order.
    var calculatorItems: [LearnView.Selection] {
        [.abvCalculator] + Self.superjuiceTypes.map { .superjuice($0) }
    }

    /// Every item the Learn library can show.
    var allItems: [LearnView.Selection] {
        allLessons.map { .lesson($0) } + calculatorItems + books.map { .book($0) }
    }

    /// Topic sections in manifest order, then Calculators, then Books.
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

        let calculators = calculatorItems.filter { item in
            trimmedQuery.isEmpty || cardModel(for: item).title.localizedStandardContains(trimmedQuery)
        }
        sections.append(
            LibrarySection(id: Self.calculatorsSectionID, title: String(localized: "Calculators"), items: calculators)
        )
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
                image: .remote(URL(string: book.image))
            )
        case .abvCalculator:
            LibraryCardModel(
                title: String(localized: "ABV Calculator"),
                subtitle: String(localized: "Work out the alcohol by volume of any drink."),
                image: .asset("abv")
            )
        case .superjuice(let juiceType):
            LibraryCardModel(
                title: String(localized: "\(juiceType.capitalizingFirstLetter()) Superjuice"),
                subtitle: String(localized: "Turn a few fruits into a litre of juice."),
                image: .asset(juiceType)
            )
        }
    }

    /// Maps stored recent IDs back to items, keeping order and dropping IDs that no longer exist.
    func recentItems(from ids: [String]) -> [LearnView.Selection] {
        let itemsByID = Dictionary(allItems.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        return ids.compactMap { itemsByID[$0] }
    }
}
