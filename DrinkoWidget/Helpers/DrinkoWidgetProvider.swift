//
//  DrinkoWidgetProvider.swift
//  DrinkoWidget
//
//  Created by Filippo Cilia on 04/04/2026.
//

import WidgetKit

struct DrinkoWidgetProvider: AppIntentTimelineProvider {
    typealias Configuration = CocktailWidgetConfigurationIntent

    // The placeholder is what users see in the gallery before real data loads.
    // It should be instant and use a representative sample model.
    func placeholder(in context: Context) -> DrinkoWidgetEntry {
        DrinkoWidgetEntry(
            date: .now,
            cocktail: DrinkoWidgetCatalog.nullCocktail,
            imageData: nil,
            showsIngredients: true
        )
    }

    // Snapshot is the fast path WidgetKit uses for previews and transient loads.
    // We compute the same daily cocktail here so previews match the real widget.
    func snapshot(for configuration: Configuration, in context: Context) async -> DrinkoWidgetEntry {
        await makeEntry(for: .now, configuration: configuration)
    }

    // The real timeline rotates once per day. Every size uses the same entry,
    // then WidgetKit asks again at the next day boundary.
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
        let imageData = DrinkoWidgetImageStore.imageData(for: cocktail)

        return DrinkoWidgetEntry(
            date: date,
            cocktail: cocktail,
            imageData: imageData,
            showsIngredients: configuration.showsIngredients
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
