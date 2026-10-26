//
//  FavoriteIDs.swift
//  DrinkoPro
//

import Foundation

/// Reads and writes the favourite cocktail IDs in the App Group, in the format `Favorites`
/// saves. Shared with the widget, which can't use `Favorites` (it is `@Observable` app state).
nonisolated enum FavoriteIDs {
    /// The saved IDs, or an empty set when nothing is saved or the data can't be read.
    static func load(from defaults: UserDefaults) -> Set<String> {
        guard let data = defaults.data(forKey: AppGroup.favoritesKey) else { return [] }
        return decode(data) ?? []
    }

    /// Saves the IDs as sorted JSON, so the stored bytes don't depend on set ordering.
    static func save(_ ids: Set<String>, to defaults: UserDefaults) {
        guard let data = encode(ids) else {
            print("Warning: Unable to save favorite cocktails")
            return
        }
        defaults.set(data, forKey: AppGroup.favoritesKey)
    }

    /// Adds `id` if it is missing, otherwise removes it. Returns whether it is now a favourite.
    @discardableResult
    static func toggle(_ id: String, in defaults: UserDefaults) -> Bool {
        var ids = load(from: defaults)
        let isFavorite = ids.insert(id).inserted
        if !isFavorite { ids.remove(id) }
        save(ids, to: defaults)
        return isFavorite
    }

    static func decode(_ data: Data) -> Set<String>? {
        try? JSONDecoder().decode(Set<String>.self, from: data)
    }

    static func encode(_ ids: Set<String>) -> Data? {
        try? JSONEncoder().encode(ids.sorted())
    }
}
