import Testing
@testable import DrinkoPro

@Suite("Recents deck layout")
struct RecentsDeckLayoutTests {
    @Test func frontItemIsPositionZero() {
        #expect(RecentsDeckLayout.position(ofIndex: 0, frontIndex: 0, count: 3) == 0)
        #expect(RecentsDeckLayout.position(ofIndex: 2, frontIndex: 2, count: 3) == 0)
    }

    @Test func positionsWrapAround() {
        #expect(RecentsDeckLayout.position(ofIndex: 0, frontIndex: 1, count: 3) == 2)
        #expect(RecentsDeckLayout.position(ofIndex: 2, frontIndex: 1, count: 3) == 1)
    }

    @Test func nextAndPreviousCycle() {
        #expect(RecentsDeckLayout.nextFront(2, count: 3) == 0)
        #expect(RecentsDeckLayout.previousFront(0, count: 3) == 2)
        #expect(RecentsDeckLayout.nextFront(0, count: 1) == 0)
    }

    @Test func emptyDeckIsSafe() {
        #expect(RecentsDeckLayout.nextFront(0, count: 0) == 0)
        #expect(RecentsDeckLayout.previousFront(0, count: 0) == 0)
        #expect(RecentsDeckLayout.position(ofIndex: 0, frontIndex: 0, count: 0) == 0)
    }

    @Test func peekStepsAlternateRightThenLeftAndMoveOutward() {
        let steps = (0..<5).map { RecentsDeckLayout.peekSteps(forPosition: $0) }
        #expect(steps == [0, 1, -1, 2, -2])
    }
}
