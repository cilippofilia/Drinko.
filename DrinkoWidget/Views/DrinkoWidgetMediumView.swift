//
//  DrinkoWidgetMediumView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 4/5/26.
//

import SwiftUI
import WidgetKit

struct DrinkoWidgetMediumView: View {
    let cocktail: WidgetCocktail
    let imageData: Data?

    let visibleIngredientCount = 6

    var body: some View {
        HStack(spacing: 0) {
            ZStack {
                DrinkoWidgetMediumTitleArtView(hiddenTopRow: false, hiddenMiddleRow: false, hiddenBottomRow: true)

                WidgetRenderedImage(imageData: imageData)
                    .frame(maxHeight: .infinity, alignment: .bottom)

                DrinkoWidgetMediumTitleArtView(hiddenTopRow: true, hiddenMiddleRow: true, hiddenBottomRow: false)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(cocktail.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(3)

                ForEach(cocktail.ingredients.prefix(visibleIngredientCount)) { ingredient in
                    Text(ingredient.name.capitalized)
                        .font(.caption)
                        .foregroundStyle(.primary)
                }

                if cocktail.ingredients.count > visibleIngredientCount {
                    Text("see more...")
                        .foregroundStyle(.gray)
                        .font(.caption)
                        .padding(.top, 2)
                }
            }
            .minimumScaleFactor(0.8)
            .padding(.leading, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
    }
}

struct DrinkoWidgetMediumView_Previews: PreviewProvider {
    static var previews: some View {
        DrinkoWidgetMediumView(
            cocktail: DrinkoWidgetCatalog.nullCocktail,
            imageData: nil
        )
        .containerBackground(.background, for: .widget)
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
