//
//  CloudSyncedKey.swift
//  DrinkoPro
//

import Foundation

/// A `UserDefaults` value that `CloudSync` mirrors to iCloud, under the same key name.
struct CloudSyncedKey: Equatable {
    /// The local `UserDefaults` suite holding the value.
    enum Suite {
        /// `AppGroup.defaults`, shared with the widget.
        case appGroup
        /// `UserDefaults.standard`.
        case standard
    }

    /// How the value is checked, and merged on a device's first sync.
    enum Rule {
        /// JSON-encoded `Set<String>` of favorite cocktail IDs; both sides are unioned.
        case favorites
        /// `[String]` of recent IDs, newest first; iCloud's come first.
        case recents
        /// A `String` setting; iCloud's value wins.
        case setting
    }

    let name: String
    let suite: Suite
    let rule: Rule

    /// Every value that syncs.
    static let all: [CloudSyncedKey] = [
        CloudSyncedKey(name: AppGroup.favoritesKey, suite: .appGroup, rule: .favorites),
        CloudSyncedKey(name: RecentsStore.storageKey(for: .learn), suite: .standard, rule: .recents),
        CloudSyncedKey(name: RecentsStore.storageKey(for: .cocktails), suite: .standard, rule: .recents),
        CloudSyncedKey(name: CocktailListSource.storageKey, suite: .standard, rule: .setting),
        CloudSyncedKey(name: CocktailUnitPreference.storageKey, suite: .standard, rule: .setting),
        CloudSyncedKey(name: LibraryLayout.learnStorageKey, suite: .standard, rule: .setting),
        CloudSyncedKey(name: LibraryLayout.cocktailsStorageKey, suite: .standard, rule: .setting),
        CloudSyncedKey(name: CollapsedSections.learnStorageKey, suite: .standard, rule: .setting),
        CloudSyncedKey(name: CollapsedSections.cocktailsStorageKey, suite: .standard, rule: .setting),
        CloudSyncedKey(name: DetailSection.storageKey, suite: .standard, rule: .setting)
    ]
}
