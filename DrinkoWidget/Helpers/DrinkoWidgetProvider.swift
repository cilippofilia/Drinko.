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
            mainSpirit: DrinkoWidgetCatalog.nullCocktail.mainSpirit
        )
    }

    // Uses the same daily pick as the timeline so the gallery matches the real widget.
    func snapshot(for configuration: Configuration, in context: Context) async -> DrinkoWidgetEntry {
        await makeEntry(for: .now, configuration: configuration)
    }

    // One entry per day; WidgetKit asks again at the next day boundary.
    func timeline(for configuration: Configuration, in context: Context) async -> Timeline<DrinkoWidgetEntry> {
        let currentDate = Date.now
        let entry = await makeEntry(for: currentDate, configuration: configuration)
        return Timeline(
            entries: [entry],
            policy: .after(DrinkoWidgetCatalog.nextRefreshDate(after: currentDate))
        )
    }

    private func makeEntry(for date: Date, configuration: Configuration) async -> DrinkoWidgetEntry {
        let cocktails = Bundle.main.decode([WidgetCocktail].self, from: "cocktails.json")
        let shots = Bundle.main.decode([WidgetCocktail].self, from: "shots.json")

        let favoriteIDs = loadFavoriteIDs()
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
            mainSpirit: cocktail.mainSpirit
        )
    }

    private func loadFavoriteIDs() -> Set<String> {
        guard let data = AppGroup.defaults.data(forKey: AppGroup.favoritesKey),
              let ids = try? JSONDecoder().decode(Set<String>.self, from: data) else {
            return []
        }
        return ids
    }
}
