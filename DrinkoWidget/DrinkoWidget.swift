//
//  DrinkoWidget.swift
//  DrinkoWidget
//
//  Created by Filippo Cilia on 04/04/2026.
//

import WidgetKit
import SwiftUI

struct DrinkoWidget: Widget {
    let kind = "DrinkoWidget"

    var body: some WidgetConfiguration {
        // Reusing the same `kind` migrates already-placed widgets in place, with the
        // configuration's default values.
        AppIntentConfiguration(
            kind: kind,
            intent: CocktailWidgetConfigurationIntent.self,
            provider: DrinkoWidgetProvider()
        ) { entry in
            DrinkoWidgetView(entry: entry)
        }
        .configurationDisplayName("Cocktail of the Day")
        .description("Discover a new daily cocktail pick from Drinko.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
