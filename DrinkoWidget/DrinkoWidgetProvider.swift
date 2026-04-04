//
//  DrinkoWidgetProvider.swift
//  DrinkoWidget
//
//  Created by Filippo Cilia on 04/04/2026.
//

import WidgetKit

struct DrinkoWidgetProvider: TimelineProvider {
    // The placeholder is what users see in the gallery before real data loads.
    // It should be instant and use a representative sample model.
    func placeholder(in context: Context) -> DrinkoWidgetEntry {
        DrinkoWidgetEntry(
            date: .now,
            cocktail: DrinkoWidgetCatalog.sampleCocktail,
            imageData: nil
        )
    }

    // Snapshot is the fast path WidgetKit uses for previews and transient loads.
    // We compute the same daily cocktail here so previews match the real widget.
    func getSnapshot(in context: Context, completion: @escaping (DrinkoWidgetEntry) -> Void) {
        completion(makeEntry(for: .now))
    }

    // The real timeline rotates once per day. Every size uses the same entry,
    // then WidgetKit asks again at the next day boundary.
    func getTimeline(in context: Context, completion: @escaping (Timeline<DrinkoWidgetEntry>) -> Void) {
        let currentDate = Date.now
        let timeline = Timeline(
            entries: [makeEntry(for: currentDate)],
            policy: .after(DrinkoWidgetCatalog.nextRefreshDate(after: currentDate))
        )
        completion(timeline)
    }

    private func makeEntry(for date: Date) -> DrinkoWidgetEntry {
        let cocktails = DrinkoWidgetCatalog.loadCocktails()
        let cocktail = DrinkoWidgetCatalog.cocktailOfTheDay(from: cocktails, on: date)
        let imageData = DrinkoWidgetImageStore.imageData(for: cocktail)
        return DrinkoWidgetEntry(date: date, cocktail: cocktail, imageData: imageData)
    }
}
