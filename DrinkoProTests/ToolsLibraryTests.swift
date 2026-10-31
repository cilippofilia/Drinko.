import SwiftUI
import Testing
@testable import DrinkoPro

@MainActor
@Suite("Tools library content")
struct ToolsLibraryTests {
    @Test func selectionIDsAreStableAndUnique() {
        #expect(ToolsView.Selection.abvCalculator.id == "abv")
        #expect(ToolsView.Selection.superjuice("lime").id == "superjuice:lime")
        #expect(ToolsView.Selection.cabinetDiscovery.id == "discovery")

        let ids = (ToolsLibrary.discoverItems + ToolsLibrary.calculatorItems).map(\.id)
        #expect(Set(ids).count == ids.count)
    }

    @Test func sectionsListEveryToolInOrder() {
        let sections = ToolsLibrary.sections
        #expect(sections.map(\.id) == ["tools"])
        #expect(sections.first?.items == [.cabinetDiscovery, .abvCalculator, .superjuice("lime"), .superjuice("lemon")])
    }

    @Test func cardModels() {
        #expect(ToolsLibrary.cardModel(for: .abvCalculator).image == .asset("abv"))
        #expect(ToolsLibrary.cardModel(for: .abvCalculator).imageContentMode == .fill)
        #expect(ToolsLibrary.cardModel(for: .superjuice("lemon")).image == .asset("lemon"))
        #expect(ToolsLibrary.cardModel(for: .cabinetDiscovery).image == .asset("cabinet-discovery"))
    }

    @Test func sidebarSymbols() {
        #expect(ToolsLibrary.sidebarSymbol(for: .abvCalculator) == "percent")
        #expect(ToolsLibrary.sidebarSymbol(for: .superjuice("lime")) == "drop")
        #expect(ToolsLibrary.sidebarSymbol(for: .cabinetDiscovery) == "cabinet")
    }
}
