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

    @Test func offsetsPutNextCardsRightAndPreviousCardsLeft() {
        let offsets = (0..<5).map { RecentsDeckLayout.offset(ofIndex: $0, frontIndex: 0, count: 5) }
        #expect(offsets == [0, 1, 2, -2, -1])
    }

    @Test func offsetsFollowTheFrontCardAndWrap() {
        let offsets = (0..<5).map { RecentsDeckLayout.offset(ofIndex: $0, frontIndex: 3, count: 5) }
        #expect(offsets == [2, -2, -1, 0, 1])
    }

    @Test func evenDeckPutsTheExtraCardOnTheRight() {
        let offsets = (0..<4).map { RecentsDeckLayout.offset(ofIndex: $0, frontIndex: 0, count: 4) }
        #expect(offsets == [0, 1, 2, -1])
    }

    @Test func emptyDeckOffsetIsZero() {
        #expect(RecentsDeckLayout.offset(ofIndex: 0, frontIndex: 0, count: 0) == 0)
    }

    @Test func oddDeckFansOutSymmetrically() {
        let steps = [0, 1, 2, -2, -1].map { RecentsDeckLayout.fanSteps(forOffset: $0, count: 5) }
        #expect(steps == [0, 1, 2, -2, -1])
    }

    @Test func evenDeckTucksTheExtraCardBehindTheFront() {
        let steps = [0, 1, 2, -1].map { RecentsDeckLayout.fanSteps(forOffset: $0, count: 4) }
        #expect(steps == [0, 1, 0, -1])
        #expect(RecentsDeckLayout.fanSteps(forOffset: 1, count: 2) == 0)
    }
}
