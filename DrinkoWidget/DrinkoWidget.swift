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
        // This widget has no per-instance settings, so a static configuration is enough.
        StaticConfiguration(kind: kind, provider: DrinkoWidgetProvider()) { entry in
            DrinkoWidgetView(entry: entry)
        }
        .configurationDisplayName("Cocktail of the Day")
        .description("Discover a new daily cocktail pick from Drinko.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
