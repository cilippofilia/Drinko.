//
//  DrinkoWidgetFavoriteButton.swift
//  DrinkoWidget
//

import AppIntents
import SwiftUI
import WidgetKit

/// The heart that adds or removes the widget's cocktail from the favourites without opening
/// the app. Shows only an icon, with the action as its accessibility label.
struct DrinkoWidgetFavoriteButton: View {
    @Environment(\.widgetRenderingMode) private var renderingMode

    let entry: DrinkoWidgetEntry

    var body: some View {
        let ink = WidgetInk(renderingMode: renderingMode)
        let title: LocalizedStringKey = entry.isFavorite ? "Remove from favourites" : "Add to favourites"

        Button(intent: ToggleWidgetFavoriteIntent(cocktailID: entry.cocktail.id)) {
            Label(title, systemImage: entry.isFavorite ? "heart.fill" : "heart")
                .labelStyle(.iconOnly)
                .font(.title3)
                .foregroundStyle(ink.primary)
        }
        .buttonStyle(.plain)
    }
}
