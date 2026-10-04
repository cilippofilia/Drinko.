//
//  LearnCollapseMigration.swift
//  DrinkoPro
//

import Foundation

/// One-time migration from the old per-topic `*Collapsed` bools to the single
/// `learnCollapsedSections` `CollapsedSections` value used by the shared `LibraryView`.
enum LearnCollapseMigration {
    /// Old storage key -> new library section ID.
    private static let keyMapping: [String: String] = [
        "basicLessonsCollapsed": "basic-lessons",
        "barPrepsCollapsed": "bar-preps",
        "basicSpiritsCollapsed": "basic-spirits",
        "advancedSpiritsCollapsed": "advanced-spirits",
        "liqueursCollapsed": "liqueurs",
        "advancedLessonsCollapsed": "advanced-lessons",
        "syrupsCollapsed": "syrups",
        "calculatorsCollapsed": "calculators",
        "booksCollapsed": "books"
    ]

    private static let newKey = "learnCollapsedSections"

    /// Builds the migrated `CollapsedSections`, or `nil` if there is nothing to migrate
    /// (the new key already exists, or none of the old keys were ever set to `true`).
    static func migrated(from defaults: UserDefaults) -> CollapsedSections? {
        guard defaults.object(forKey: newKey) == nil else { return nil }

        var collapsedSections = CollapsedSections()
        var foundAny = false
        for (oldKey, sectionID) in keyMapping where defaults.bool(forKey: oldKey) {
            collapsedSections.toggle(sectionID)
            foundAny = true
        }

        return foundAny ? collapsedSections : nil
    }

    /// Runs the migration once: if needed, writes the new key and removes the old ones.
    static func runIfNeeded(using defaults: UserDefaults = .standard) {
        guard let migrated = migrated(from: defaults) else { return }

        defaults.set(migrated.rawValue, forKey: newKey)
        for oldKey in keyMapping.keys {
            defaults.removeObject(forKey: oldKey)
        }
    }
}
