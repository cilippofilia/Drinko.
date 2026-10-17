//
//  ToolsLibrary.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 06/10/2026.
//

import Foundation

enum ToolsLibrary {
    static let calculatorsSectionID = "calculators"
    private nonisolated static let superjuiceTypes = ["lime", "lemon"]

    nonisolated static var calculatorItems: [ToolsView.Selection] {
        [.abvCalculator] + superjuiceTypes.map { .superjuice($0) }
    }

    static var sections: [LibrarySection<ToolsView.Selection>] {
        [LibrarySection(id: calculatorsSectionID, title: String(localized: "Calculators"), items: calculatorItems)]
    }

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

    /// `Tab` takes a symbol, not the card's artwork.
    static func sidebarSymbol(for item: ToolsView.Selection) -> String {
        switch item {
        case .abvCalculator: "percent"
        case .superjuice: "drop"
        }
    }

    /// Keyed on the whole phrase, since the raw juice type is English-only.
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
