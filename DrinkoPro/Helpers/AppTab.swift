//
//  AppTab.swift
//  DrinkoPro
//

import Foundation

/// Every destination the iOS tab view can select: the five main tabs, plus the iPad
/// sidebar-only rows that open a main tab's page with a preset.
enum AppTab: Hashable {
    case learn
    /// A Learn page showing one library section (a `LearnTopic.id` or `LessonsViewModel.booksSectionID`).
    case learnSection(String)
    case cabinet
    /// A Cabinet page showing one category (`Category.id`).
    case cabinetCategory(UUID)
    case cocktails
    /// A Cocktails page with a fixed filter.
    case cocktailFilter(CocktailsViewModel.FilterOption)
    case tools
    /// One tool, opened directly.
    case tool(ToolsView.Selection)
    case settings

    /// The cocktail filters that get their own sidebar row, in display order.
    static let sidebarCocktailFilters: [CocktailsViewModel.FilterOption] = [
        .shotsOnly, .favoritesOnly, .userCreatedOnly
    ]

    /// The main tab this destination belongs to; a main tab is its own parent.
    var parent: AppTab {
        switch self {
        case .learn, .learnSection: .learn
        case .cabinet, .cabinetCategory: .cabinet
        case .cocktails, .cocktailFilter: .cocktails
        case .tools, .tool: .tools
        case .settings: .settings
        }
    }

    /// Whether this destination only exists in the iPad sidebar (not in the tab bar).
    var isSidebarOnly: Bool {
        self != parent
    }
}

extension AppTab {
    /// A string encoding for scene storage (not a `RawRepresentable` conformance —
    /// that would make the standard library pick its raw-value-based `==`/`hash(into:)`
    /// over the synthesized case-based ones, silently breaking equality here).
    ///
    /// Main tabs keep the strings the old `String?` tab tags used, so a tab saved by an
    /// earlier version still restores. Sidebar rows append `/<detail>`.
    private enum Name: String {
        case learn = "Learn"
        case cabinet = "Cabinet"
        case cocktails = "Cocktails"
        case tools = "Tools"
        case settings = "Settings"
    }

    /// Decodes a saved tab. A detail that no longer exists (a deleted topic, an unknown
    /// tool or filter, a malformed category ID) decodes to the main tab instead.
    init?(rawValue: String) {
        let parts = rawValue.split(separator: "/", maxSplits: 1).map(String.init)
        guard let first = parts.first, let name = Name(rawValue: first) else { return nil }
        let detail = parts.count > 1 ? parts[1] : nil

        switch name {
        case .learn:
            if let detail, LessonsViewModel.sectionTitle(for: detail) != nil {
                self = .learnSection(detail)
            } else {
                self = .learn
            }
        case .cabinet:
            self = detail.flatMap(UUID.init(uuidString:)).map(AppTab.cabinetCategory) ?? .cabinet
        case .cocktails:
            self = detail.flatMap(CocktailsViewModel.FilterOption.init(rawValue:))
                .map(AppTab.cocktailFilter) ?? .cocktails
        case .tools:
            self = detail.flatMap(ToolsView.Selection.init(id:)).map(AppTab.tool) ?? .tools
        case .settings:
            self = .settings
        }
    }

    var rawValue: String {
        switch self {
        case .learn: Name.learn.rawValue
        case .learnSection(let id): "\(Name.learn.rawValue)/\(id)"
        case .cabinet: Name.cabinet.rawValue
        case .cabinetCategory(let id): "\(Name.cabinet.rawValue)/\(id.uuidString)"
        case .cocktails: Name.cocktails.rawValue
        case .cocktailFilter(let filter): "\(Name.cocktails.rawValue)/\(filter.rawValue)"
        case .tools: Name.tools.rawValue
        case .tool(let selection): "\(Name.tools.rawValue)/\(selection.id)"
        case .settings: Name.settings.rawValue
        }
    }
}
