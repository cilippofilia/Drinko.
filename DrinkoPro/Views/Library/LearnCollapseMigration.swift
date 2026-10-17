//
//  LearnCollapseMigration.swift
//  DrinkoPro
//

import Foundation

/// One-time migration from the old per-topic `*Collapsed` bools to `learnCollapsedSections`.
enum LearnCollapseMigration {
    private static let keyMapping: [String: String] = [
        "basicLessonsCollapsed": "basic-lessons",
        "barPrepsCollapsed": "bar-preps",
        "basicSpiritsCollapsed": "basic-spirits",
        "advancedSpiritsCollapsed": "advanced-spirits",
        "liqueursCollapsed": "liqueurs",
        "advancedLessonsCollapsed": "advanced-lessons",
        "syrupsCollapsed": "syrups",
        "booksCollapsed": "books"
    ]

    /// Old keys with no Learn section left (Calculators moved to Tools): removed, not migrated.
    private static let retiredKeys = ["calculatorsCollapsed"]

    private static let newKey = CollapsedSections.learnStorageKey

    /// `nil` when the new key already exists or no old key was ever `true`.
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

    static func runIfNeeded(using defaults: UserDefaults = .standard) {
        guard let migrated = migrated(from: defaults) else { return }

        defaults.set(migrated.rawValue, forKey: newKey)
        for oldKey in Array(keyMapping.keys) + retiredKeys {
            defaults.removeObject(forKey: oldKey)
        }
    }
}
