import Foundation
import SwiftUI
import Testing
@testable import DrinkoPro

@Suite("Library models")
struct LibraryModelTests {
    @Test func collapsedSectionsStartsEmpty() {
        let sections = CollapsedSections()
        #expect(!sections.contains("basic-lessons"))
    }

    @Test func toggleAddsThenRemovesAnID() {
        var sections = CollapsedSections()
        sections.toggle("books")
        #expect(sections.contains("books"))
        sections.toggle("books")
        #expect(!sections.contains("books"))
    }

    @Test func rawValueRoundTrips() throws {
        var sections = CollapsedSections()
        sections.toggle("books")
        sections.toggle("syrups")
        let restored = try #require(CollapsedSections(rawValue: sections.rawValue))
        #expect(restored == sections)
    }

    @Test func invalidRawValueGivesEmptySet() throws {
        let restored = try #require(CollapsedSections(rawValue: "not json"))
        #expect(restored == CollapsedSections())
    }

    @Test func searchingForcesSectionsOpen() {
        var sections = CollapsedSections()
        sections.toggle("books")
        #expect(sections.isCollapsed("books", whileSearching: false))
        #expect(!sections.isCollapsed("books", whileSearching: true))
        #expect(!sections.isCollapsed("syrups", whileSearching: false))
    }

    @Test func layoutTogglesAndUsesSharedKey() {
        #expect(LibraryLayout.list.toggled == .grid)
        #expect(LibraryLayout.grid.toggled == .list)
        #expect(LibraryLayout.storageKey == "libraryLayout")
        #expect(LibraryLayout(rawValue: "garbage") == nil)
    }

    @Test func cardModelDefaultsHaveNoSubtitleOrProgress() {
        let model = LibraryCardModel(title: "Negroni", image: .symbol("wineglass"))
        #expect(model.subtitle == nil)
        #expect(model.progress == nil)
        #expect(model.imageContentMode == .fill)
    }
}
