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
            cocktail: DrinkoWidgetCatalog.nullCocktail,
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
        let cocktails = Bundle.main.decode([WidgetCocktail].self, from: "cocktails.json")

        // Calculate a unique integer for the given day since the start of the calendar era.
        // Modding by the cocktail count cycles through all cocktails evenly,
        // ensuring a different cocktail is shown each day without any persistence.
        let dayIndex = Calendar.autoupdatingCurrent.ordinality(of: .day, in: .era, for: date) ?? 0
        let cocktail = cocktails[dayIndex % cocktails.count]

        let imageData = DrinkoWidgetImageStore.imageData(for: cocktail)
        return DrinkoWidgetEntry(date: date, cocktail: cocktail, imageData: imageData)
    }
}
