//
//  DrinkoWidgetEntry.swift
//  DrinkoWidget
//
//  Created by Filippo Cilia on 04/04/2026.
//

import WidgetKit

// Each entry represents the widget's content for one point in time.
// Besides the required date, we include the chosen cocktail so all widget sizes
// can render the same "daily pick" consistently.
struct DrinkoWidgetEntry: TimelineEntry {
    let date: Date
    let cocktail: WidgetCocktail
    let imageData: Data?

    var deepLinkURL: URL? {
        URL(string: "drinko://cocktail/\(cocktail.id)")
    }
}
