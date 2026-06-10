//
//  DrinkoWidget.swift
//  DrinkoWidget
//
//  Created by Filippo Cilia on 04/04/2026.
//

import WidgetKit
import SwiftUI

struct DrinkoWidget: Widget {
    // `kind` is the internal identifier WidgetKit uses to distinguish widgets.
    let kind = "DrinkoWidget"

    var body: some WidgetConfiguration {
        // Lets users pick a content source and toggle ingredients via "Edit Widget".
        // Reusing the same `kind` means already-placed widgets migrate in place
        // with the configuration's default values.
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
