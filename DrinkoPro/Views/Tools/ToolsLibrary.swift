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
                title: String(localized: "\(juiceType.capitalizingFirstLetter()) Superjuice"),
                subtitle: String(localized: "Turn a few fruits into a litre of juice."),
                image: .asset(juiceType)
            )
        }
    }
}
