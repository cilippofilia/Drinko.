import Foundation
import Testing
@testable import DrinkoPro

@MainActor
@Suite("DetailSection")
struct DetailSectionTests {
    @Test func sectionIDsAreStableAndDistinct() {
        #expect(DetailSection.allCases.map(\.rawValue) == ["ingredients", "procedure", "suggested"])
        #expect(DetailSection.storageKey == "detailCollapsedSections")
    }

    @Test func togglingCollapsesOnlyThatSection() {
        var collapsed = CollapsedSections()
        collapsed.toggle(DetailSection.suggested.rawValue)

        #expect(collapsed.contains(DetailSection.suggested.rawValue))
        #expect(!collapsed.contains(DetailSection.ingredients.rawValue))
        #expect(!collapsed.contains(DetailSection.procedure.rawValue))
    }

    @Test func collapsedStateSurvivesRawValueRoundTrip() throws {
        var collapsed = CollapsedSections()
        collapsed.toggle(DetailSection.procedure.rawValue)

        let restored = try #require(CollapsedSections(rawValue: collapsed.rawValue))
        #expect(restored.contains(DetailSection.procedure.rawValue))
        #expect(restored == collapsed)
    }
}
