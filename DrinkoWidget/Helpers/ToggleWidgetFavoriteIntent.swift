//
//  ToggleWidgetFavoriteIntent.swift
//  DrinkoWidget
//

import AppIntents
import WidgetKit

/// The heart button on the widget. Runs in the widget extension, so it writes the shared
/// favourites directly; the app picks the change up and syncs it when it next becomes active.
struct ToggleWidgetFavoriteIntent: AppIntent {
    static let title: LocalizedStringResource = "Toggle Favourite"
    static let isDiscoverable = false

    @Parameter(title: "Cocktail ID")
    var cocktailID: String

    init() {}

    init(cocktailID: String) {
        self.cocktailID = cocktailID
    }

    func perform() async throws -> some IntentResult {
        FavoriteIDs.toggle(cocktailID, in: AppGroup.defaults)
        WidgetCenter.shared.reloadTimelines(ofKind: AppGroup.widgetKind)
        return .result()
    }
}
