//
//  DrinkoWidgetMediumView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 4/5/26.
//

import SwiftUI
import WidgetKit

struct DrinkoWidgetMediumView: View {
    let entry: DrinkoWidgetEntry

    var body: some View {
        HStack(spacing: 16) {
            // Claims its width first, so the sticker keeps the full height and the text
            // takes whatever is left.
            WidgetStickerImage(stickerData: entry.stickerData)
                .frame(maxHeight: .infinity)
                .layoutPriority(1)

            Group {
                if entry.showsIngredients {
                    // Adds the method, glass and garnish under the ingredients when they fit,
                    // and drops them for long names or ingredient lists.
                    ViewThatFits(in: .vertical) {
                        DrinkoWidgetMediumColumn(entry: entry, showsIngredients: true, showsDetails: true)
                        DrinkoWidgetMediumColumn(entry: entry, showsIngredients: true, showsDetails: false)
                    }
                } else {
                    DrinkoWidgetMediumColumn(entry: entry, showsIngredients: false, showsDetails: true)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
    }
}

private struct DrinkoWidgetMediumColumn: View {
    @Environment(\.widgetRenderingMode) private var renderingMode

    let entry: DrinkoWidgetEntry
    let showsIngredients: Bool
    let showsDetails: Bool

    var body: some View {
        let ink = WidgetInk(renderingMode: renderingMode)

        VStack(alignment: .leading, spacing: 6) {
            Text(entry.cocktail.isShot ? "Shot of the Day" : "Cocktail of the Day")
                .font(.caption2)
                .bold()
                .textCase(.uppercase)
                .foregroundStyle(ink.secondary)
                .lineLimit(1)

            Text(entry.cocktail.name)
                .font(.system(.title2, design: .serif))
                .fontWeight(.heavy)
                .foregroundStyle(ink.primary)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .widgetAccentable()
                .lineLimit(2)
                .minimumScaleFactor(0.6)

            if showsIngredients {
                Text(entry.cocktail.ingredientList)
                    .font(.caption)
                    .foregroundStyle(ink.secondary)
                    .lineLimit(3)
            }

            if showsDetails {
                VStack(alignment: .leading, spacing: 2) {
                    DrinkoWidgetDetailRow(label: "Method", value: entry.cocktail.method)
                    DrinkoWidgetDetailRow(label: "Glass", value: entry.cocktail.glass)
                    DrinkoWidgetDetailRow(label: "Garnish", value: entry.cocktail.garnish)
                }
            }
        }
    }
}

private struct DrinkoWidgetDetailRow: View {
    @Environment(\.widgetRenderingMode) private var renderingMode

    let label: LocalizedStringKey
    let value: String

    var body: some View {
        let ink = WidgetInk(renderingMode: renderingMode)

        HStack(spacing: 4) {
            Text(label)
                .foregroundStyle(ink.secondary)
            Text(value.capitalized)
                .foregroundStyle(ink.primary)
        }
        .font(.caption)
        .lineLimit(1)
    }
}

#if DEBUG
#Preview("Ingredients", as: .systemMedium) {
    DrinkoWidget()
} timeline: {
    DrinkoWidgetEntry.preview()
}

#Preview("Details", as: .systemMedium) {
    DrinkoWidget()
} timeline: {
    DrinkoWidgetEntry.preview(showsIngredients: false)
}

#Preview("Long name", as: .systemMedium) {
    DrinkoWidget()
} timeline: {
    DrinkoWidgetEntry.longNamePreview
}

#Preview("Shot", as: .systemMedium) {
    DrinkoWidget()
} timeline: {
    DrinkoWidgetEntry.shotPreview
}
#endif
