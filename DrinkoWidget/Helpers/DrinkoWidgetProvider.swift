//
//  DrinkoWidgetProvider.swift
//  DrinkoWidget
//
//  Created by Filippo Cilia on 04/04/2026.
//

import WidgetKit

struct DrinkoWidgetProvider: AppIntentTimelineProvider {
    typealias Configuration = CocktailWidgetConfigurationIntent

    func placeholder(in context: Context) -> DrinkoWidgetEntry {
        DrinkoWidgetEntry(
            date: .now,
            cocktail: DrinkoWidgetCatalog.nullCocktail,
            stickerData: nil,
            showsIngredients: true,
            isFavorite: false,
            mainSpirit: DrinkoWidgetCatalog.nullCocktail.mainSpirit
        )
    }

    // Uses the same daily pick as the timeline so the gallery matches the real widget.
    func snapshot(for configuration: Configuration, in context: Context) async -> DrinkoWidgetEntry {
        await makeEntry(for: .now, configuration: configuration, isPreview: context.isPreview)
    }

    // One entry per day; WidgetKit asks again at the next day boundary.
    func timeline(for configuration: Configuration, in context: Context) async -> Timeline<DrinkoWidgetEntry> {
        let currentDate = Date.now
        let entry = await makeEntry(for: currentDate, configuration: configuration, isPreview: false)
        return Timeline(
            entries: [entry],
            policy: .after(DrinkoWidgetCatalog.nextRefreshDate(after: currentDate))
        )
    }

    private func makeEntry(for date: Date, configuration: Configuration, isPreview: Bool) async -> DrinkoWidgetEntry {
        // The gallery preview never touches the network; real timelines may fetch with a short timeout.
        let (cocktails, shots) = await WidgetContentLoader.live(allowsNetwork: !isPreview).drinks()

        let favoriteIDs = FavoriteIDs.load(from: AppGroup.defaults)
        let pool = DrinkoWidgetCatalog.pool(
            for: configuration.source.widgetDrinkSource,
            cocktails: cocktails,
            shots: shots,
            favoriteIDs: favoriteIDs
        )

        let cocktail = DrinkoWidgetCatalog.dailyPick(from: pool, on: date) ?? DrinkoWidgetCatalog.nullCocktail
        let stickerData = DrinkoWidgetImageStore.stickerData(for: cocktail)

        return DrinkoWidgetEntry(
            date: date,
            cocktail: cocktail,
            stickerData: stickerData,
            showsIngredients: configuration.showsIngredients,
            isFavorite: favoriteIDs.contains(cocktail.id),
            mainSpirit: cocktail.mainSpirit
        )
    }
}
