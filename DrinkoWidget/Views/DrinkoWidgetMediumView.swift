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
    let showsIngredients: Bool

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
                    .foregroundStyle(.black)
                    .lineLimit(3)

                if showsIngredients {
                    ForEach(cocktail.ingredients.prefix(visibleIngredientCount)) { ingredient in
                        Text(ingredient.name.capitalized)
                            .font(.caption)
                            .foregroundStyle(.black)
                    }

                    if cocktail.ingredients.count > visibleIngredientCount {
                        Text("see more...")
                            .foregroundStyle(.gray)
                            .font(.caption)
                            .padding(.top, 2)
                    }
                } else {
                    DrinkoWidgetDetailRow(label: "Method", value: cocktail.method)
                    DrinkoWidgetDetailRow(label: "Glass", value: cocktail.glass)
                    DrinkoWidgetDetailRow(label: "Garnish", value: cocktail.garnish)
                }
            }
            .minimumScaleFactor(0.8)
            .padding(.leading, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
    }
}

// A simple "label: value" caption row, used to fill the medium widget's
// detail column when ingredients are hidden.
private struct DrinkoWidgetDetailRow: View {
    let label: LocalizedStringKey
    let value: String

    var body: some View {
        (Text(label) + Text(": ") + Text(value.capitalized))
            .font(.caption)
            .foregroundStyle(.black)
    }
}

struct DrinkoWidgetMediumView_Previews: PreviewProvider {
    static var previews: some View {
        DrinkoWidgetMediumView(
            cocktail: DrinkoWidgetCatalog.nullCocktail,
            imageData: nil,
            showsIngredients: true
        )
        .containerBackground(.background, for: .widget)
        .previewContext(WidgetPreviewContext(family: .systemMedium))

        DrinkoWidgetMediumView(
            cocktail: DrinkoWidgetCatalog.nullCocktail,
            imageData: nil,
            showsIngredients: false
        )
        .containerBackground(.background, for: .widget)
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
