//
//  CocktailShareCard.swift
//  DrinkoPro
//

import SwiftUI

/// The recipe card image people share: banner, ingredients, method, glass and a Drinko mark.
/// Rendered off-screen by `CocktailShareItem`, always light and at a fixed size.
struct CocktailShareCard: View {
    let cocktail: Cocktail
    let artwork: ShareCardArtwork
    let lines: [IngredientLine]

    /// The card's width in points; the rendered PNG is 3× this.
    static let width: CGFloat = 360

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            CocktailShareBanner(name: cocktail.name, artwork: artwork)

            VStack(alignment: .leading, spacing: 6) {
                Text("Ingredients")
                    .font(.headline)

                ForEach(lines) { line in
                    HStack {
                        Text(line.quantity, format: .number.precision(.fractionLength(0...2)))
                        Text(line.unit)
                        Text(line.name)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                CocktailDetailSectionView(cocktail: cocktail, kind: .method)
                CocktailDetailSectionView(cocktail: cocktail, kind: .glass)
            }

            HStack {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 20)
                Text(verbatim: "Drinko")
                    .font(.footnote.bold())
            }
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding()
        .frame(width: Self.width)
        .background(.white)
        .environment(\.colorScheme, .light)
        .dynamicTypeSize(.large)
    }
}

#if DEBUG
#Preview {
    CocktailShareCard(
        cocktail: .example,
        artwork: .glass(Cocktail.example.glassArtwork, tint: MainSpirit.gin.colorName),
        lines: Cocktail.example.ingredients.map {
            IngredientLine(ingredient: $0, selectedUnit: "ml", showsOriginalUnits: false)
        }
    )
}
#endif
