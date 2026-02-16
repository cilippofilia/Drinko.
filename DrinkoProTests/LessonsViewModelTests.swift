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
}
