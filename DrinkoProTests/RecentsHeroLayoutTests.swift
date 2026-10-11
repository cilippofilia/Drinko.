import Foundation
import Testing
@testable import DrinkoPro

@Suite("Recents hero layout")
struct RecentsHeroLayoutTests {
    // MARK: Looping

    @Test func loopsOnlyWithThreeOrMoreItems() {
        #expect(!RecentsHeroLayout.isLooping(count: 0))
        #expect(!RecentsHeroLayout.isLooping(count: 2))
        #expect(RecentsHeroLayout.isLooping(count: 3))
    }

    @Test func loopingLaysOutCopiesOtherwiseJustTheItems() {
        #expect(RecentsHeroLayout.slotCount(count: 4) == 4 * RecentsHeroLayout.loopCopies)
        #expect(RecentsHeroLayout.slotCount(count: 2) == 2)
        #expect(RecentsHeroLayout.slotCount(count: 0) == 0)
    }

    @Test func slotsMapBackOntoItems() {
        #expect(RecentsHeroLayout.itemIndex(forSlot: 0, count: 3) == 0)
        #expect(RecentsHeroLayout.itemIndex(forSlot: 7, count: 3) == 1)
        #expect(RecentsHeroLayout.itemIndex(forSlot: -1, count: 3) == 2)
        #expect(RecentsHeroLayout.itemIndex(forSlot: 5, count: 0) == 0)
    }

    @Test func homeSlotIsTheItemInTheMiddleCopy() {
        let home = RecentsHeroLayout.homeSlot(forIndex: 1, count: 3)
        #expect(home == 3 * (RecentsHeroLayout.loopCopies / 2) + 1)
        #expect(RecentsHeroLayout.itemIndex(forSlot: home, count: 3) == 1)
        // Without looping the slot is the index.
        #expect(RecentsHeroLayout.homeSlot(forIndex: 1, count: 2) == 1)
    }

    @Test func recentersOnlyNearTheEnds() {
        let count = 3
        let last = RecentsHeroLayout.slotCount(count: count) - 1
        // Near the start or end: the same item, back in the middle copy.
        let homeOfFirstCopy = RecentsHeroLayout.homeSlot(forIndex: 1, count: count)
        let homeOfLastSlot = RecentsHeroLayout.homeSlot(forIndex: last, count: count)
        #expect(RecentsHeroLayout.recenteredSlot(1, count: count) == homeOfFirstCopy)
        #expect(RecentsHeroLayout.recenteredSlot(last, count: count) == homeOfLastSlot)
        // Anywhere else stays put.
        #expect(RecentsHeroLayout.recenteredSlot(40, count: count) == 40)
        // Without looping nothing moves.
        #expect(RecentsHeroLayout.recenteredSlot(0, count: 2) == 0)
    }

    @Test func steppingStopsAtTheEndsOfTheSlots() {
        #expect(RecentsHeroLayout.nextSlot(0, count: 2) == 1)
        #expect(RecentsHeroLayout.nextSlot(1, count: 2) == 1)
        #expect(RecentsHeroLayout.previousSlot(1, count: 2) == 0)
        #expect(RecentsHeroLayout.previousSlot(0, count: 2) == 0)
        #expect(RecentsHeroLayout.nextSlot(0, count: 0) == 0)
        let home = RecentsHeroLayout.homeSlot(forIndex: 2, count: 3)
        // Looping: stepping past the last item lands on the next copy's first item.
        #expect(RecentsHeroLayout.itemIndex(forSlot: RecentsHeroLayout.nextSlot(home, count: 3), count: 3) == 0)
    }

    // MARK: Sizing

    @Test func itemWidthIsAFractionOfTheContainerUpToACap() {
        #expect(RecentsHeroLayout.itemWidth(forContainerWidth: 100) == 36)
        #expect(RecentsHeroLayout.itemWidth(forContainerWidth: 2000) == RecentsHeroLayout.maximumItemWidth)
        #expect(RecentsHeroLayout.itemWidth(forContainerWidth: -5) == 0)
    }

    // MARK: Scroll progress

    @Test func positionBetweenItemsSplitsIntoNeighboursAndFraction() throws {
        let position = try #require(RecentsHeroLayout.position(forFractionalIndex: 1.25, count: 4))
        #expect(position.lowerIndex == 1)
        #expect(position.upperIndex == 2)
        #expect(abs(position.fraction - 0.25) < 0.0001)
    }

    @Test func positionOnAnItemHasNoFraction() {
        #expect(RecentsHeroLayout.position(forFractionalIndex: 2, count: 4)
            == RecentsHeroLayout.Position(lowerIndex: 2, upperIndex: 3, fraction: 0))
    }

    @Test func positionIsClampedAtBothEnds() {
        #expect(RecentsHeroLayout.position(forFractionalIndex: -0.6, count: 3)
            == RecentsHeroLayout.Position(lowerIndex: 0, upperIndex: 1, fraction: 0))
        #expect(RecentsHeroLayout.position(forFractionalIndex: 7, count: 3)
            == RecentsHeroLayout.Position(lowerIndex: 2, upperIndex: 2, fraction: 0))
    }

    @Test func positionHandlesEmptySingleAndNonFiniteInput() {
        #expect(RecentsHeroLayout.position(forFractionalIndex: 0, count: 0) == nil)
        #expect(RecentsHeroLayout.position(forFractionalIndex: 0.5, count: 1)
            == RecentsHeroLayout.Position(lowerIndex: 0, upperIndex: 0, fraction: 0))
        #expect(RecentsHeroLayout.position(forFractionalIndex: .nan, count: 3)?.lowerIndex == 0)
    }

    @Test func itemPositionMapsSlotsOntoItemsAndWrapsAtCopyBoundaries() {
        // Slot 5 of a 3-item loop is item 2, and slot 6 is back to item 0.
        #expect(RecentsHeroLayout.itemPosition(forFractionalSlot: 5.25, itemCount: 3, snapsFraction: false)
            == RecentsHeroLayout.Position(lowerIndex: 2, upperIndex: 0, fraction: 0.25))
        #expect(RecentsHeroLayout.itemPosition(forFractionalSlot: 0, itemCount: 0, snapsFraction: false) == nil)
    }

    @Test func snappingRoundsTheFractionToTheNearerItem() {
        let nearFirst = RecentsHeroLayout.itemPosition(forFractionalSlot: 1.3, itemCount: 4, snapsFraction: true)
        #expect(nearFirst?.fraction == 0)
        let nearSecond = RecentsHeroLayout.itemPosition(forFractionalSlot: 1.7, itemCount: 4, snapsFraction: true)
        #expect(nearSecond?.fraction == 1)
    }

    @Test func interpolationRunsFromStartToEnd() {
        #expect(RecentsHeroLayout.interpolated(from: 0.2, to: 0.8, fraction: 0) == 0.2)
        #expect(RecentsHeroLayout.interpolated(from: 0.2, to: 0.8, fraction: 1) == 0.8)
        #expect(abs(RecentsHeroLayout.interpolated(from: 0.2, to: 0.8, fraction: 0.5) - 0.5) < 0.0001)
    }

    @Test func blendedLuminanceMixesTheNeighbouringItems() {
        let luminances = [0.1, 0.9, 0.5]
        #expect(RecentsHeroLayout.blendedLuminance(
            atFractionalSlot: 0, itemLuminances: luminances, snapsFraction: false, fallback: 0.3) == 0.1)
        let halfway = RecentsHeroLayout.blendedLuminance(
            atFractionalSlot: 0.5, itemLuminances: luminances, snapsFraction: false, fallback: 0.3)
        #expect(abs(halfway - 0.5) < 0.0001)
        // Reduce Motion snaps to the nearer item.
        let snapped = RecentsHeroLayout.blendedLuminance(
            atFractionalSlot: 0.6, itemLuminances: luminances, snapsFraction: true, fallback: 0.3)
        #expect(abs(snapped - 0.9) < 0.0001)
        // The last item blends back into the first only on a looping carousel's next slot.
        let wrapped = RecentsHeroLayout.blendedLuminance(
            atFractionalSlot: 2, itemLuminances: luminances, snapsFraction: false, fallback: 0.3)
        #expect(abs(wrapped - 0.5) < 0.0001)
    }

    @Test func blendedLuminanceFallsBackWithoutItems() {
        #expect(RecentsHeroLayout.blendedLuminance(
            atFractionalSlot: 1, itemLuminances: [], snapsFraction: false, fallback: 0.3) == 0.3)
    }

    // MARK: Backdrops

    @Test func tintedStickerBecomesAColorBackdrop() {
        let image = LibraryImage.sticker(URL(string: "https://example.com/a.png"), tint: "Dr. Gold")
        #expect(RecentsHeroLayout.backdrop(for: image) == .color("Dr. Gold"))
    }

    @Test func untintedStickerIsNeutral() {
        #expect(RecentsHeroLayout.backdrop(for: .sticker(nil, tint: nil)) == .neutral)
    }

    @Test func remotePhotoBecomesAPhotoBackdrop() throws {
        let url = try #require(URL(string: "https://example.com/a.jpg"))
        #expect(RecentsHeroLayout.backdrop(for: .remote(url)) == .photo(url))
        #expect(RecentsHeroLayout.backdrop(for: .remote(nil)) == .neutral)
    }

    @Test func assetsAndSymbolsAreNeutral() {
        #expect(RecentsHeroLayout.backdrop(for: .asset("coupe")) == .neutral)
        #expect(RecentsHeroLayout.backdrop(for: .symbol("wineglass")) == .neutral)
    }

    // MARK: Legibility

    @Test func luminanceWeighsGreenMostAndBlueLeast() {
        #expect(RecentsHeroLayout.luminance(red: 0, green: 0, blue: 0) == 0)
        #expect(abs(RecentsHeroLayout.luminance(red: 1, green: 1, blue: 1) - 1) < 0.0001)
        let red = RecentsHeroLayout.luminance(red: 1, green: 0, blue: 0)
        let green = RecentsHeroLayout.luminance(red: 0, green: 1, blue: 0)
        let blue = RecentsHeroLayout.luminance(red: 0, green: 0, blue: 1)
        #expect(green > red)
        #expect(red > blue)
    }

    @Test func darkBackdropsGetLightTextAndLightBackdropsGetDarkText() {
        #expect(RecentsHeroLayout.textStyle(forLuminance: 0.1) == .light)
        #expect(RecentsHeroLayout.textStyle(forLuminance: 0.95) == .dark)
        #expect(RecentsHeroLayout.textStyle(forLuminance: RecentsHeroLayout.darkTextThreshold) == .light)
    }

    // MARK: Navigation bar

    @Test func barTitleWaitsUntilTheContentScrollsPastTheThreshold() {
        #expect(!RecentsHeroLayout.hasScrolledUnderBar(barBottom: 0, threshold: 24))
        // Pulled down past the top.
        #expect(!RecentsHeroLayout.hasScrolledUnderBar(barBottom: -80, threshold: 24))
        #expect(!RecentsHeroLayout.hasScrolledUnderBar(barBottom: 24, threshold: 24))
        #expect(RecentsHeroLayout.hasScrolledUnderBar(barBottom: 25, threshold: 24))
        #expect(RecentsHeroLayout.hasScrolledUnderBar(barBottom: 600, threshold: 24))
    }
}
