//
//  DrinkoWidgetView.swift
//  DrinkoWidget
//
//  Created by Filippo Cilia on 04/04/2026.
//

import SwiftUI
import UIKit
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
                DrinkoWidgetSmallView(cocktail: entry.cocktail, imageData: entry.imageData)
            case .systemMedium:
                DrinkoWidgetMediumView(cocktail: entry.cocktail, imageData: entry.imageData)
            case .systemLarge:
                DrinkoWidgetLargeView(cocktail: entry.cocktail)
            default:
                DrinkoWidgetMediumView(cocktail: entry.cocktail, imageData: entry.imageData)
            }
        }
        // The entire widget opens the matching cocktail detail when tapped.
        .widgetURL(entry.deepLinkURL)
        .containerBackground(.white, for: .widget)
    }
}

private struct DrinkoWidgetSmallView: View {
    let cocktail: DrinkoWidgetCocktail
    let imageData: Data?

    var body: some View {
        ZStack {
            Text(cocktail.name)
                .font(.system(size: 36, weight: .heavy))
                .fontWidth(.expanded)
                .foregroundStyle(.black)
                .lineLimit(2)
                .minimumScaleFactor(0.5)
                .frame(maxHeight: .infinity, alignment: .top)

            WidgetRenderedImage(imageData: imageData)
                .scaleEffect(2.3)
                .offset(y: 85)
        }
    }
}

private struct DrinkoWidgetMediumView: View {
    let cocktail: DrinkoWidgetCocktail
    let imageData: Data?

    var body: some View {
        HStack {
            WidgetRenderedImage(imageData: imageData)
                .frame(maxWidth: .infinity, alignment: .bottom)
                .scaleEffect(2)
                .offset(y: 50)

            VStack(alignment: .leading) {
                Text(cocktail.name)
                    .bold()
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)

                ForEach(cocktail.ingredients, id: \.name) { ingredient in
                    HStack(spacing: 0) {
                        Group {
                            Text(ingredient.quantity)
                                .padding(.trailing, 2)
                            Text(ingredient.unit)
                                .padding(.trailing, 5)
                        }
                        .font(.subheadline)

                        Text(ingredient.name)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Spacer()
                    }
                }
            }
        }
        .overlay(alignment: .topLeading) {
            Text("Daily Pick:")
                .font(.caption)
                .foregroundStyle(.black)
        }
    }
}

private struct DrinkoWidgetLargeView: View {
    let cocktail: DrinkoWidgetCocktail

    var body: some View {
        VStack(alignment: .leading) {
            Text("Daily Pick")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(cocktail.name)
                .font(.title)
                .bold()
                .lineLimit(2)
            Label(cocktail.glass.capitalized, systemImage: "wineglass")
                .font(.subheadline)
            Label(cocktail.method.capitalized, systemImage: "figure.barre")
                .font(.subheadline)

            Divider()

            Text("Ingredients")
                .font(.headline)
            ForEach(cocktail.ingredients.prefix(4), id: \.name) { ingredient in
                Text(ingredient.name.capitalized)
                    .font(.subheadline)
                    .lineLimit(1)
            }
            Spacer()
        }
    }
}

private struct WidgetPlaceholderView: View {
    var body: some View {
        Rectangle()
            .fill(.fill.quaternary)
            .overlay {
                Image(systemName: "wineglass")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
            }
    }
}

private struct WidgetRenderedImage: View {
    let imageData: Data?

    var body: some View {
        if let imageData,
           let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
        } else {
            WidgetPlaceholderView()
        }
    }
}

#Preview("Small", as: .systemSmall) {
    DrinkoWidget()
} timeline: {
    DrinkoWidgetEntry(
        date: .now,
        cocktail: DrinkoWidgetCatalog.sampleCocktail,
        imageData: nil
    )
}

#Preview("Medium", as: .systemMedium) {
    DrinkoWidget()
} timeline: {
    DrinkoWidgetEntry(
        date: .now,
        cocktail: DrinkoWidgetCatalog.sampleCocktail,
        imageData: nil
    )
}

#Preview("Large", as: .systemLarge) {
    DrinkoWidget()
} timeline: {
    DrinkoWidgetEntry(
        date: .now,
        cocktail: DrinkoWidgetCatalog.sampleCocktail,
        imageData: nil
    )
}
