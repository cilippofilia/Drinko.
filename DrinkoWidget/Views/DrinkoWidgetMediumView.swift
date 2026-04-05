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

    var body: some View {
        HStack(spacing: 0) {
            ZStack {
                VStack {
                    Text("Cocktail")
                    Spacer()
                    HStack {
                        Text("of")
                        Spacer()
                        Text("the")
                    }
                    Spacer()
                    HStack {
                        Text("D")
                        Spacer()
                        Text("a")
                        Spacer()
                        Text("y")
                    }
                    .opacity(0)
                }
                .textCase(.uppercase)
                .font(.system(size: 36, weight: .heavy, design: .serif))
                .foregroundStyle(.black.gradient)
                .lineLimit(3)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                WidgetRenderedImage(imageData: imageData)
                    .frame(maxHeight: .infinity, alignment: .bottom)

                VStack {
                    Text("Cocktail")
                        .opacity(0)
                    Spacer()
                    HStack {
                        Text("of")
                        Spacer()
                        Text("the")
                    }
                    .opacity(0)
                    Spacer()
                    HStack {
                        Text("D")
                        Spacer()
                        Text("a")
                        Spacer()
                        Text("y")
                    }
                }
                .textCase(.uppercase)
                .font(.system(size: 36, weight: .heavy, design: .serif))
                .foregroundStyle(.black.gradient)
                .lineLimit(3)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            }

            VStack(alignment: .leading, spacing: 4) {
                Text(cocktail.name)
                    .font(.headline)
                    .foregroundStyle(.black.gradient)
                    .lineLimit(3)

                ForEach(cocktail.ingredients.prefix(6)) { ingredient in
                    Text(ingredient.name.capitalized)
                        .font(.caption)
                }

                if cocktail.ingredients.count > 6 {
                    Text("see more...")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                        .padding(.top, 2)
                }
            }
            .minimumScaleFactor(0.8)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct DrinkoWidgetMediumView_Previews: PreviewProvider {
    static var previews: some View {
        DrinkoWidgetMediumView(
            cocktail: DrinkoWidgetCatalog.nullCocktail,
            imageData: nil
        )
        .containerBackground(.white, for: .widget)
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
