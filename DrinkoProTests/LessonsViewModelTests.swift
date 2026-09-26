import XCTest
@testable import DrinkoPro

@MainActor
final class LessonsViewModelTests: XCTestCase {
    func testTopicsListMatchesExpectedOrder() {
        let viewModel = LessonsViewModel()

        XCTAssertEqual(
            viewModel.topics,
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
    }

    func testLessonCollectionsLoadFromBundle() {
        let viewModel = LessonsViewModel()

        XCTAssertFalse(viewModel.basicLessons.isEmpty)
        XCTAssertFalse(viewModel.advancedLessons.isEmpty)
        XCTAssertFalse(viewModel.barPreps.isEmpty)
        XCTAssertFalse(viewModel.basicSpirits.isEmpty)
        XCTAssertFalse(viewModel.advancedSpirits.isEmpty)
        XCTAssertFalse(viewModel.liqueurs.isEmpty)
        XCTAssertFalse(viewModel.syrups.isEmpty)
        XCTAssertFalse(viewModel.books.isEmpty)
    }

    func testAllLessonsConcatenationOrder() {
        let viewModel = LessonsViewModel()

        let expectedIds =
            viewModel.basicLessons.map(\.id) +
            viewModel.advancedLessons.map(\.id) +
            viewModel.barPreps.map(\.id) +
            viewModel.basicSpirits.map(\.id) +
            viewModel.advancedSpirits.map(\.id) +
            viewModel.liqueurs.map(\.id) +
            viewModel.syrups.map(\.id)

        XCTAssertEqual(viewModel.allLessons.map(\.id), expectedIds)
    }

    func testGetLessonsForTopicReturnsExpectedCollection() {
        let viewModel = LessonsViewModel()

        XCTAssertEqual(viewModel.getLessons(for: "basic-lessons"), viewModel.basicLessons)
        XCTAssertEqual(viewModel.getLessons(for: "advanced-lessons"), viewModel.advancedLessons)
        XCTAssertEqual(viewModel.getLessons(for: "bar-preps"), viewModel.barPreps)
        XCTAssertEqual(viewModel.getLessons(for: "basic-spirits"), viewModel.basicSpirits)
        XCTAssertEqual(viewModel.getLessons(for: "advanced-spirits"), viewModel.advancedSpirits)
        XCTAssertEqual(viewModel.getLessons(for: "liqueurs"), viewModel.liqueurs)
        XCTAssertEqual(viewModel.getLessons(for: "syrups"), viewModel.syrups)
        XCTAssertTrue(viewModel.getLessons(for: "unknown-topic").isEmpty)
    }

    func testFilteredLessonsWithEmptyQueryReturnsEverything() {
        let viewModel = LessonsViewModel()

        XCTAssertEqual(viewModel.filteredLessons(for: "basic-lessons", matching: ""), viewModel.basicLessons)
        XCTAssertEqual(viewModel.filteredLessons(for: "basic-lessons", matching: "   "), viewModel.basicLessons)
    }

    func testFilteredLessonsMatchesTitleOrDescriptionCaseInsensitively() throws {
        let viewModel = LessonsViewModel()
        let lesson = try XCTUnwrap(viewModel.basicLessons.first)

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
        let viewModel = LessonsViewModel()

        XCTAssertTrue(viewModel.filteredBooks(matching: "zzzzz-no-such-book-zzzzz").isEmpty)
    }

    func testHasResultsIsTrueForEmptyQuery() {
        let viewModel = LessonsViewModel()

        XCTAssertTrue(viewModel.hasResults(matching: ""))
    }

    func testHasResultsIsTrueWhenABookMatches() throws {
        let viewModel = LessonsViewModel()
        let book = try XCTUnwrap(viewModel.books.first)

        XCTAssertTrue(viewModel.hasResults(matching: book.title))
    }

    func testHasResultsIsTrueWhenALessonMatches() throws {
        let viewModel = LessonsViewModel()
        let lesson = try XCTUnwrap(viewModel.basicLessons.first)

        XCTAssertTrue(viewModel.hasResults(matching: lesson.title))
    }

    func testHasResultsIsFalseWhenNothingMatches() {
        let viewModel = LessonsViewModel()

        XCTAssertFalse(viewModel.hasResults(matching: "zzzzz-no-such-content-zzzzz"))
    }
}
