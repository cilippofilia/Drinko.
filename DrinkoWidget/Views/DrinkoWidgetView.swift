//
//  DrinkoWidgetView.swift
//  DrinkoWidget
//
//  Created by Filippo Cilia on 04/04/2026.
//

import SwiftUI
import WidgetKit

struct DrinkoWidgetView: View {
    // WidgetKit tells us which family is being rendered so we can add detail
    // as the widget gets more space.
    @Environment(\.widgetFamily) private var family

    let entry: DrinkoWidgetEntry

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                DrinkoWidgetSmallView(entry: entry)
            default:
                DrinkoWidgetMediumView(entry: entry)
            }
        }
        .containerBackground(for: .widget) {
            WidgetStickerBackdrop(tint: entry.mainSpirit?.colorName)
        }
        // The entire widget opens the matching cocktail detail when tapped.
        .widgetURL(entry.deepLinkURL)
    }
}

#if DEBUG
#Preview("Small", as: .systemSmall) {
    DrinkoWidget()
} timeline: {
    DrinkoWidgetEntry.preview()
}

#Preview("Small, long name", as: .systemSmall) {
    DrinkoWidget()
} timeline: {
    DrinkoWidgetEntry.longNamePreview
}

#Preview("Medium", as: .systemMedium) {
    DrinkoWidget()
} timeline: {
    DrinkoWidgetEntry.preview()
}

#Preview("Medium, details", as: .systemMedium) {
    DrinkoWidget()
} timeline: {
    DrinkoWidgetEntry.preview(showsIngredients: false)
}

#Preview("Medium, long name", as: .systemMedium) {
    DrinkoWidget()
} timeline: {
    DrinkoWidgetEntry.longNamePreview
}
#endif
