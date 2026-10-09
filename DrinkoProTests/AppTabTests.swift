//
//  AppTabTests.swift
//  DrinkoProTests
//

import Foundation
import Testing
@testable import DrinkoPro

@MainActor
@Suite("AppTab")
struct AppTabTests {
    private let categoryID = UUID()

    private var everyTab: [AppTab] {
        [
            .learn, .learnSection("bar-preps"), .learnSection(LessonsViewModel.booksSectionID),
            .cabinet, .cabinetCategory(categoryID),
            .cocktails, .cocktailFilter(.shotsOnly), .cocktailFilter(.favoritesOnly), .cocktailFilter(.userCreatedOnly),
            .tools, .tool(.abvCalculator), .tool(.superjuice("lime")),
            .settings
        ]
    }

    @Test func rawValueRoundTrips() {
        for tab in everyTab {
            #expect(AppTab(rawValue: tab.rawValue) == tab, "\(tab.rawValue)")
        }
    }

    @Test func legacyTagsDecodeToMainTabs() {
        #expect(AppTab(rawValue: "Learn") == .learn)
        #expect(AppTab(rawValue: "Cabinet") == .cabinet)
        #expect(AppTab(rawValue: "Cocktails") == .cocktails)
        #expect(AppTab(rawValue: "Tools") == .tools)
        #expect(AppTab(rawValue: "Settings") == .settings)
    }

    @Test func staleDetailsDecodeToParent() {
        #expect(AppTab(rawValue: "Learn/not-a-topic") == .learn)
        #expect(AppTab(rawValue: "Cabinet/not-a-uuid") == .cabinet)
        #expect(AppTab(rawValue: "Cocktails/notAFilter") == .cocktails)
        #expect(AppTab(rawValue: "Tools/superjuice:grape") == .tools)
    }

    @Test func unknownNamesDecodeToNil() {
        #expect(AppTab(rawValue: "") == nil)
        #expect(AppTab(rawValue: "MacCabinet") == nil)
        #expect(AppTab(rawValue: "learn") == nil)
    }

    @Test func parentAndSidebarOnly() {
        #expect(AppTab.learnSection("bar-preps").parent == .learn)
        #expect(AppTab.cabinetCategory(categoryID).parent == .cabinet)
        #expect(AppTab.cocktailFilter(.shotsOnly).parent == .cocktails)
        #expect(AppTab.tool(.abvCalculator).parent == .tools)
        for main in [AppTab.learn, .cabinet, .cocktails, .tools, .settings] {
            #expect(main.parent == main)
            #expect(!main.isSidebarOnly)
        }
        #expect(AppTab.tool(.abvCalculator).isSidebarOnly)
    }

    @Test func sidebarCocktailFiltersAreShotsFavoritesMine() {
        #expect(AppTab.sidebarCocktailFilters == [.shotsOnly, .favoritesOnly, .userCreatedOnly])
    }

    @Test func toolSelectionDecodesOnlyRealTools() {
        #expect(ToolsView.Selection(id: "abv") == .abvCalculator)
        #expect(ToolsView.Selection(id: "superjuice:lemon") == .superjuice("lemon"))
        #expect(ToolsView.Selection(id: "superjuice:grape") == nil)
        #expect(ToolsView.Selection(id: "") == nil)
    }

    @Test func learnSectionTitles() {
        #expect(LessonsViewModel.sectionTitle(for: "bar-preps") == String(localized: "Bar Preps"))
        #expect(LessonsViewModel.sectionTitle(for: LessonsViewModel.booksSectionID) == String(localized: "Books"))
        #expect(LessonsViewModel.sectionTitle(for: "nope") == nil)
        #expect(LessonsViewModel.librarySectionIDs == LearnTopic.all.map(\.id) + [LessonsViewModel.booksSectionID])
    }

    @Test func fittedUsesParentWhenCompact() {
        let tab = AppTab.cocktailFilter(.shotsOnly)
        #expect(tab.fitted(isCompact: true, categoryIDs: []) == .cocktails)
        #expect(tab.fitted(isCompact: false, categoryIDs: []) == tab)
        #expect(AppTab.settings.fitted(isCompact: true, categoryIDs: []) == .settings)
    }

    @Test func fittedDropsDeletedCategory() {
        let tab = AppTab.cabinetCategory(categoryID)
        #expect(tab.fitted(isCompact: false, categoryIDs: [categoryID]) == tab)
        #expect(tab.fitted(isCompact: false, categoryIDs: [UUID()]) == .cabinet)
    }

    @Test func deepLinkSelectsCocktails() throws {
        let model = AppNavigationModel()
        model.handle(url: try #require(URL(string: "drinko://cocktail/negroni")))
        #expect(model.selectedTab == .cocktails)
        #expect(model.consumePendingCocktailID() == "negroni")

        let untouched = AppNavigationModel()
        untouched.handle(url: try #require(URL(string: "https://cocktail/negroni")))
        #expect(untouched.selectedTab == .learn)
    }
}
