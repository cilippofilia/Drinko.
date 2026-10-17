//
//  DrinkoWidgetSmallView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 4/5/26.
//

import SwiftUI
import WidgetKit

struct DrinkoWidgetSmallView: View {
    @Environment(\.widgetRenderingMode) private var renderingMode

    let entry: DrinkoWidgetEntry

    var body: some View {
        let ink = WidgetInk(renderingMode: renderingMode)
        VStack(spacing: 0) {
            WidgetStickerImage(stickerData: entry.stickerData)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Text(entry.cocktail.name)
                .font(.system(.headline, design: .serif))
                .fontWeight(.heavy)
                .foregroundStyle(ink.primary)
                .widgetAccentable()
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#if DEBUG
#Preview("Short name - no ingredients", as: .systemSmall) {
    DrinkoWidget()
} timeline: {
    DrinkoWidgetEntry.preview(showsIngredients: false)
}
#Preview("Long name preview", as: .systemSmall) {
    DrinkoWidget()
} timeline: {
    DrinkoWidgetEntry.longNamePreview
}
#endif
