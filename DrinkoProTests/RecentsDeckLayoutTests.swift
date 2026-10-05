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

    @Test func showsAtMostTwoCardsPerSide() {
        #expect(RecentsDeckLayout.visibleStepsPerSide(count: 9) == 2)
        #expect(RecentsDeckLayout.visibleStepsPerSide(count: 5) == 2)
        #expect(RecentsDeckLayout.visibleStepsPerSide(count: 4) == 1)
        #expect(RecentsDeckLayout.visibleStepsPerSide(count: 1) == 0)
    }

    @Test func hiddenCardsWaitJustPastTheVisibleOnes() {
        let steps = [0, 1, 2, 3, 4, -4, -3, -2, -1].map { RecentsDeckLayout.drumSteps(forOffset: $0, count: 9) }
        #expect(steps == [0, 1, 2, 3, 3, -3, -3, -2, -1])
        #expect(RecentsDeckLayout.drumSteps(forOffset: 2, count: 4) == 2)
    }

    @Test func onlyTheVisibleSlotsAreShownAtRest() {
        let visibility = [0, 1, 2, 3, -3].map {
            RecentsDeckLayout.drumVisibility(forSteps: $0, dragProgress: 0, count: 9)
        }
        #expect(visibility == [1, 1, 1, 0, 0])
        // An even deck's extra card stays hidden so the drum looks symmetric.
        #expect(RecentsDeckLayout.drumVisibility(forSteps: 2, dragProgress: 0, count: 4) == 0)
    }

    @Test func dragFadesTheWaitingCardIn() {
        #expect(RecentsDeckLayout.drumVisibility(forSteps: 3, dragProgress: -0.5, count: 9) == 0.5)
        #expect(RecentsDeckLayout.drumVisibility(forSteps: 3, dragProgress: -1, count: 9) == 1)
    }

    @Test func drumAnglesSpreadCardsEvenlyAroundTheFront() {
        let angles = [0, 1, 2, -2, -1].map { RecentsDeckLayout.drumAngle(forSteps: $0, dragProgress: 0) }
        #expect(angles == [0, 36, 72, -72, -36])
    }

    @Test func dragTurnsTheWholeDrum() {
        #expect(RecentsDeckLayout.drumAngle(forSteps: 0, dragProgress: 0.5) == 18)
        #expect(RecentsDeckLayout.drumAngle(forSteps: 1, dragProgress: -1) == 0)
    }

    @Test func drumAngleNeverPassesAQuarterTurn() {
        #expect(RecentsDeckLayout.drumAngle(forSteps: 2, dragProgress: 1) == 90)
        #expect(RecentsDeckLayout.drumAngle(forSteps: -2, dragProgress: -1) == -90)
    }
}
