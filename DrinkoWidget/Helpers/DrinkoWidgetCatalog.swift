//
//  DrinkoWidgetCatalog.swift
//  DrinkoWidget
//
//  Created by Filippo Cilia on 04/04/2026.
//

import SwiftUI

enum DrinkoWidgetCatalog {
    static func nextRefreshDate(
        after date: Date = .now,
        calendar: Calendar = .current
    ) -> Date {
        let startOfDay = calendar.startOfDay(for: date)
        return calendar.date(byAdding: .day, value: 1, to: startOfDay)
            ?? date.addingTimeInterval(86_400)
    }

    static let nullCocktail: WidgetCocktail = .init(
        id: "test-id",
        name: "Test Name",
        method: "shake",
        glass: "highball",
        garnish: "orange wheel",
        ice: "cubed",
        extra: "-",
        ingredients: [
            .init(name: "Spirit 1", quantity: 30.0, unit: "ml"),
            .init(name: "Spirit 2", quantity: 30.0, unit: "ml"),
            .init(name: "Sour stuff 1", quantity: 15.0, unit: "ml"),
            .init(name: "Sweet stuff 1", quantity: 15.0, unit: "ml"),
            .init(name: "Some weird ingredient", quantity: 3.0, unit: "barspoons")
        ]
    )
}
