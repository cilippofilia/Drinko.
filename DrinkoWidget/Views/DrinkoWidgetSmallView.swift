//
//  DrinkoWidgetSmallView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 4/5/26.
//

import SwiftUI
import WidgetKit

struct DrinkoWidgetSmallView: View {
    let cocktail: WidgetCocktail
    let imageData: Data?

    var body: some View {
        ZStack {
            Text(cocktail.name)
                .font(.system(size: 36, weight: .heavy, design: .serif))
                .foregroundStyle(.primary)
                .widgetAccentable()
                .lineLimit(3)
                .minimumScaleFactor(0.5)
                .frame(maxHeight: .infinity, alignment: .top)

            WidgetRenderedImage(imageData: imageData)
                .scaleEffect(1.25)
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
    }
}

struct DrinkoWidgetSmallView_Previews: PreviewProvider {
    static var previews: some View {
        DrinkoWidgetSmallView(cocktail: DrinkoWidgetCatalog.nullCocktail, imageData: nil)
            .containerBackground(.background, for: .widget)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
