import SwiftUI
import Testing
@testable import DrinkoPro

@MainActor
@Suite("Tools library content")
struct ToolsLibraryTests {
    @Test func selectionIDsAreStableAndUnique() {
        #expect(ToolsView.Selection.abvCalculator.id == "abv")
        #expect(ToolsView.Selection.superjuice("lime").id == "superjuice:lime")

        let ids = ToolsLibrary.calculatorItems.map(\.id)
        #expect(Set(ids).count == ids.count)
    }

    @Test func sectionsListTheCalculatorsInOrder() {
        let sections = ToolsLibrary.sections
        #expect(sections.map(\.id) == ["calculators"])
        #expect(sections.first?.items == [.abvCalculator, .superjuice("lime"), .superjuice("lemon")])
    }

    @Test func cardModels() {
        #expect(ToolsLibrary.cardModel(for: .abvCalculator).image == .asset("abv"))
        #expect(ToolsLibrary.cardModel(for: .abvCalculator).imageContentMode == .fill)
        #expect(ToolsLibrary.cardModel(for: .superjuice("lemon")).image == .asset("lemon"))
    }

    @Test func sidebarSymbols() {
        #expect(ToolsLibrary.sidebarSymbol(for: .abvCalculator) == "percent")
        #expect(ToolsLibrary.sidebarSymbol(for: .superjuice("lime")) == "drop")
    }
}
