//
//  ToolsLibrary.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 06/10/2026.
//

import Foundation

/// The content of the Tools library: its sections and the card shown for each tool.
enum ToolsLibrary {
    static let calculatorsSectionID = "calculators"
    private static let superjuiceTypes = ["lime", "lemon"]

    /// The calculator entries shown in the Calculators section, in display order.
    static var calculatorItems: [ToolsView.Selection] {
        [.abvCalculator] + superjuiceTypes.map { .superjuice($0) }
    }

    /// Every section the Tools library shows, in display order.
    static var sections: [LibrarySection<ToolsView.Selection>] {
        [LibrarySection(id: calculatorsSectionID, title: String(localized: "Calculators"), items: calculatorItems)]
    }

    /// Display data for one tool.
    static func cardModel(for item: ToolsView.Selection) -> LibraryCardModel {
        switch item {
        case .abvCalculator:
            LibraryCardModel(
                title: String(localized: "ABV Calculator"),
                subtitle: String(localized: "Work out the alcohol by volume of any drink."),
                image: .asset("abv")
            )
        case .superjuice(let juiceType):
            LibraryCardModel(
                title: superjuiceTitle(for: juiceType),
                subtitle: String(localized: "Turn a few fruits into a litre of juice."),
                image: .asset(juiceType)
            )
        }
    }

    /// The SF Symbol for a tool's iPad sidebar row (`Tab` takes a symbol, not the card's artwork).
    static func sidebarSymbol(for item: ToolsView.Selection) -> String {
        switch item {
        case .abvCalculator: "percent"
        case .superjuice: "drop"
        }
    }

    /// A fully-translated title for one superjuice tool, keyed on the whole phrase rather
    /// than interpolating the raw (English-only) juice type.
    private static func superjuiceTitle(for juiceType: String) -> String {
        switch juiceType {
        case "lime":
            String(localized: "Lime Superjuice")
        case "lemon":
            String(localized: "Lemon Superjuice")
        default:
            String(localized: "\(juiceType.capitalizingFirstLetter()) Superjuice")
        }
    }
}
