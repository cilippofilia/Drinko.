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
    // What the user has favourited
    private var cocktails: Set<String>

    // The key we're using to read/write in UserDefaults
    private let saveKey: String = AppGroup.favoritesKey

    // Where favorites are written, and read from first. Defaults to the App
    // Group suite so the widget extension can see them too.
    private let store: UserDefaults

    // The pre-App Group location, kept as a one-time migration source and
    // safety net.
    private let legacy: UserDefaults

    // Variable that comes in handy for animations
    public var hasEffect: Bool = false

    init(store: UserDefaults = AppGroup.defaults, legacy: UserDefaults = .standard) {
        self.store = store
        self.legacy = legacy

        // Prefer favorites already migrated into the shared suite.
        if let encodedCocktailsData = store.data(forKey: saveKey),
           let data = try? JSONDecoder().decode(Set<String>.self, from: encodedCocktailsData) {
            cocktails = data
            return
        }

        // Otherwise, migrate any favorites saved before the App Group existed.
        // We leave the legacy copy in place as a safety net.
        if let encodedCocktailsData = legacy.data(forKey: saveKey),
           let data = try? JSONDecoder().decode(Set<String>.self, from: encodedCocktailsData) {
            cocktails = data
            store.set(encodedCocktailsData, forKey: saveKey)
            return
        }

        self.cocktails = []
    }

    // Returns true if our set contains this cocktail
    func contains(_ cocktail: Cocktail) -> Bool {
        cocktails.contains(cocktail.id)
    }

    // Add cocktail to our set, updates all views, and saves the change
    func add(_ cocktail: Cocktail) {
        cocktails.insert(cocktail.id)
        hasEffect.toggle()
        save()
    }

    // Remove cocktail from our set, updates all views, and saves the change
    func remove(_ cocktail: Cocktail) {
        cocktails.remove(cocktail.id)
        hasEffect.toggle()
        save()
    }

    private func save() {
        // Write out our favorite cocktails data
        guard let data = try? JSONEncoder().encode(cocktails) else {
            print("Warning: Unable to save favorite cocktails")
            return
        }
        store.set(data, forKey: saveKey)

        // Let the widget know favorites changed so a "Favorites Only" widget
        // can pick up the new pool. This only fires on user add/remove.
        #if os(iOS)
        WidgetCenter.shared.reloadTimelines(ofKind: AppGroup.widgetKind)
        #endif
    }
}
