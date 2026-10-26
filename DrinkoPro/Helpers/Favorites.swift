//
//  Favorites.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 28/04/2023.
//

import SwiftUI
#if os(iOS)
import WidgetKit
#endif

@MainActor
@Observable
class Favorites {
    private var cocktails: Set<String>

    private let saveKey: String = AppGroup.favoritesKey

    // Defaults to the App Group suite so the widget can read favorites too.
    private let store: UserDefaults

    // The pre-App Group location, kept as a migration source and safety net.
    private let legacy: UserDefaults

    // Drives the heart animation.
    public var hasEffect: Bool = false

    /// Called after favourites change, so Siri's suggested cocktails can be refreshed.
    @ObservationIgnored var onChange: (() -> Void)?

    init(store: UserDefaults = AppGroup.defaults, legacy: UserDefaults = .standard) {
        self.store = store
        self.legacy = legacy

        // Prefer favorites already migrated into the shared suite.
        if let encodedCocktailsData = store.data(forKey: saveKey),
           let data = FavoriteIDs.decode(encodedCocktailsData) {
            cocktails = data
            return
        }

        // Otherwise, migrate any favorites saved before the App Group existed.
        // We leave the legacy copy in place as a safety net.
        if let encodedCocktailsData = legacy.data(forKey: saveKey),
           let data = FavoriteIDs.decode(encodedCocktailsData) {
            cocktails = data
            store.set(encodedCocktailsData, forKey: saveKey)
            return
        }

        self.cocktails = []
    }

    func contains(_ cocktail: Cocktail) -> Bool {
        cocktails.contains(cocktail.id)
    }

    func add(_ cocktail: Cocktail) {
        cocktails.insert(cocktail.id)
        hasEffect.toggle()
        save()
    }

    func remove(_ cocktail: Cocktail) {
        cocktails.remove(cocktail.id)
        hasEffect.toggle()
        save()
    }

    // For changes from iCloud. Unreadable data keeps the current favorites, and `hasEffect` is
    // left alone so remote changes don't animate the heart.
    func reload() {
        guard let data = store.data(forKey: saveKey),
              let loaded = FavoriteIDs.decode(data),
              loaded != cocktails else { return }
        cocktails = loaded
        reloadWidget()
        onChange?()
    }

    private func save() {
        FavoriteIDs.save(cocktails, to: store)

        reloadWidget()
        onChange?()
    }

    private func reloadWidget() {
        #if os(iOS)
        WidgetCenter.shared.reloadTimelines(ofKind: AppGroup.widgetKind)
        #endif
    }
}
