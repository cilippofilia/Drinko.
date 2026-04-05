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
        method: "",
        glass: "",
        garnish: "",
        ice: "",
        extra: "",
        ingredients: []
    )
}
