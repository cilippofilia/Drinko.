import XCTest
@testable import DrinkoPro

@MainActor
final class LessonsViewModelTests: XCTestCase {
    func testTopicManifestOrder() {
        XCTAssertEqual(
            LearnTopic.all.map(\.id),
            [
                "basic-lessons",
                "bar-preps",
                "basic-spirits",
                "advanced-spirits",
                "liqueurs",
                "advanced-lessons",
                "syrups"
            ]
        )
        XCTAssertEqual(LessonsViewModel().topics, LearnTopic.all)
    }

    func testEveryTopicLoadsLessonsFromBundle() {
        let viewModel = LessonsViewModel()

        for topic in viewModel.topics {
            XCTAssertFalse(viewModel.lessons(for: topic.id).isEmpty, "No lessons for \(topic.id)")
        }
        XCTAssertFalse(viewModel.books.isEmpty)
    }

    func testUnknownTopicHasNoLessons() {
        XCTAssertTrue(LessonsViewModel().lessons(for: "unknown-topic").isEmpty)
    }

    func testAllLessonsFollowsManifestOrder() {
        let viewModel = LessonsViewModel()
        let expectedIds = viewModel.topics.flatMap { viewModel.lessons(for: $0.id).map(\.id) }

        XCTAssertEqual(viewModel.allLessons.map(\.id), expectedIds)
    }

    func testFilteredLessonsWithEmptyQueryReturnsEverything() {
        let viewModel = LessonsViewModel()
        let basics = viewModel.lessons(for: "basic-lessons")

        XCTAssertEqual(viewModel.filteredLessons(for: "basic-lessons", matching: ""), basics)
        XCTAssertEqual(viewModel.filteredLessons(for: "basic-lessons", matching: "   "), basics)
    }

    func testFilteredLessonsMatchesTitleOrDescriptionCaseInsensitively() throws {
        let viewModel = LessonsViewModel()
        let lesson = try XCTUnwrap(viewModel.lessons(for: "basic-lessons").first)

        let byTitle = viewModel.filteredLessons(for: "basic-lessons", matching: lesson.title.uppercased())
        XCTAssertTrue(byTitle.contains(lesson))

        let byDescriptionFragment = String(lesson.description.prefix(4))
        let byDescription = viewModel.filteredLessons(for: "basic-lessons", matching: byDescriptionFragment)
        XCTAssertTrue(byDescription.contains(lesson))
    }

    func testFilteredLessonsWithNoMatchReturnsEmpty() {
        let viewModel = LessonsViewModel()

        XCTAssertTrue(
            viewModel.filteredLessons(for: "basic-lessons", matching: "zzzzz-no-such-lesson-zzzzz").isEmpty
        )
    }

    func testFilteredBooksWithEmptyQueryReturnsEverything() {
        let viewModel = LessonsViewModel()

        XCTAssertEqual(viewModel.filteredBooks(matching: ""), viewModel.books)
        XCTAssertEqual(viewModel.filteredBooks(matching: "  "), viewModel.books)
    }

    func testFilteredBooksMatchesTitleDescriptionOrAuthor() throws {
        let viewModel = LessonsViewModel()
        let book = try XCTUnwrap(viewModel.books.first)

        XCTAssertTrue(viewModel.filteredBooks(matching: book.title.uppercased()).contains(book))
        XCTAssertTrue(viewModel.filteredBooks(matching: book.author).contains(book))
    }

    func testFilteredBooksWithNoMatchReturnsEmpty() {
        XCTAssertTrue(LessonsViewModel().filteredBooks(matching: "zzzzz-no-such-book-zzzzz").isEmpty)
    }

    func testHasResultsIsTrueForEmptyQuery() {
        XCTAssertTrue(LessonsViewModel().hasResults(matching: ""))
    }

    func testHasResultsIsTrueWhenABookMatches() throws {
        let viewModel = LessonsViewModel()
        let book = try XCTUnwrap(viewModel.books.first)

        XCTAssertTrue(viewModel.hasResults(matching: book.title))
    }

    func testHasResultsIsTrueWhenALessonMatches() throws {
        let viewModel = LessonsViewModel()
        let lesson = try XCTUnwrap(viewModel.lessons(for: "basic-lessons").first)

        XCTAssertTrue(viewModel.hasResults(matching: lesson.title))
    }

    func testHasResultsIsFalseWhenNothingMatches() {
        XCTAssertFalse(LessonsViewModel().hasResults(matching: "zzzzz-no-such-content-zzzzz"))
    }
}
