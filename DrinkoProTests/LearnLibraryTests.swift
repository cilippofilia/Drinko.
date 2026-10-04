import Foundation
import SwiftUI
import Testing
@testable import DrinkoPro

@MainActor
@Suite("Learn library content")
struct LearnLibraryTests {
    let viewModel = LessonsViewModel()

    @Test func selectionIDsAreStableAndUnique() throws {
        let lesson = try #require(viewModel.allLessons.first)
        let book = try #require(viewModel.books.first)
        #expect(LearnView.Selection.lesson(lesson).id == "lesson:\(lesson.id)")
        #expect(LearnView.Selection.book(book).id == "book:\(book.id)")
        #expect(LearnView.Selection.abvCalculator.id == "abv")
        #expect(LearnView.Selection.superjuice("lime").id == "superjuice:lime")

        let ids = viewModel.allItems.map(\.id)
        #expect(Set(ids).count == ids.count)
    }

    @Test func emptyQueryReturnsManifestThenCalculatorsThenBooks() {
        let sections = viewModel.librarySections(matching: "")
        #expect(sections.map(\.id) == LearnTopic.all.map(\.id) + ["calculators", "books"])
        #expect(sections.allSatisfy { !$0.items.isEmpty })
        #expect(sections.first { $0.id == "calculators" }?.items == [.abvCalculator, .superjuice("lime"), .superjuice("lemon")])
    }

    @Test func whitespaceQueryMatchesEmptyQuery() {
        #expect(viewModel.librarySections(matching: "   ") == viewModel.librarySections(matching: ""))
    }

    @Test func queryFiltersItemsAndDropsEmptySections() throws {
        let lesson = try #require(viewModel.lessons(for: "syrups").first)
        let sections = viewModel.librarySections(matching: lesson.title)
        #expect(sections.allSatisfy { !$0.items.isEmpty })
        let syrups = try #require(sections.first { $0.id == "syrups" })
        #expect(syrups.items.contains(.lesson(lesson)))
    }

    @Test func calculatorsAreSearchable() throws {
        let sections = viewModel.librarySections(matching: "abv")
        let calculators = try #require(sections.first { $0.id == "calculators" })
        #expect(calculators.items == [.abvCalculator])
    }

    @Test func noMatchReturnsNoSections() {
        #expect(viewModel.librarySections(matching: "zzzzz-no-such-content-zzzzz").isEmpty)
    }

    @Test func recentItemsResolveInOrderAndDropUnknownIDs() throws {
        let lesson = try #require(viewModel.allLessons.first)
        let items = viewModel.recentItems(from: ["abv", "lesson:does-not-exist", "lesson:\(lesson.id)"])
        #expect(items == [.abvCalculator, .lesson(lesson)])
    }

    @Test func cardModels() throws {
        let lesson = try #require(viewModel.allLessons.first)
        let lessonModel = viewModel.cardModel(for: .lesson(lesson))
        #expect(lessonModel.title == lesson.title)
        #expect(lessonModel.subtitle == lesson.description)
        #expect(lessonModel.image == .remote(URL(string: lesson.image)))
        #expect(lessonModel.progress == nil)

        let book = try #require(viewModel.books.first)
        #expect(viewModel.cardModel(for: .book(book)).subtitle == "© \(book.author)")

        #expect(viewModel.cardModel(for: .abvCalculator).image == .asset("abv"))
        #expect(viewModel.cardModel(for: .abvCalculator).imageContentMode == .fill)
        #expect(viewModel.cardModel(for: .superjuice("lemon")).image == .asset("lemon"))
    }
}
