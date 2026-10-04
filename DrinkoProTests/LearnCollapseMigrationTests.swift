import Foundation
import Testing
@testable import DrinkoPro

@Suite("LearnCollapseMigration")
struct LearnCollapseMigrationTests {
    private func makeDefaults() throws -> UserDefaults {
        let suiteName = "LearnCollapseMigrationTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }

    @Test func migratesCollapsedOldKeysToNewSectionIDs() throws {
        let defaults = try makeDefaults()
        defaults.set(true, forKey: "basicLessonsCollapsed")
        defaults.set(true, forKey: "syrupsCollapsed")
        defaults.set(false, forKey: "barPrepsCollapsed")

        let migrated = LearnCollapseMigration.migrated(from: defaults)

        #expect(migrated != nil)
        #expect(migrated?.contains("basic-lessons") == true)
        #expect(migrated?.contains("syrups") == true)
        #expect(migrated?.contains("bar-preps") == false)
    }

    @Test func mapsEveryOldKeyToItsSectionID() throws {
        let defaults = try makeDefaults()
        let mapping: [String: String] = [
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
        for oldKey in mapping.keys {
            defaults.set(true, forKey: oldKey)
        }

        let migrated = LearnCollapseMigration.migrated(from: defaults)

        for sectionID in mapping.values {
            #expect(migrated?.contains(sectionID) == true)
        }
    }

    @Test func returnsNilWhenNoOldKeysAreSet() throws {
        let defaults = try makeDefaults()
        #expect(LearnCollapseMigration.migrated(from: defaults) == nil)
    }

    @Test func returnsNilWhenNewKeyAlreadyExists() throws {
        let defaults = try makeDefaults()
        defaults.set(true, forKey: "basicLessonsCollapsed")
        defaults.set("[]", forKey: "learnCollapsedSections")
        #expect(LearnCollapseMigration.migrated(from: defaults) == nil)
    }

    @Test func runIfNeededWritesNewKeyAndRemovesOldKeys() throws {
        let defaults = try makeDefaults()
        defaults.set(true, forKey: "basicLessonsCollapsed")
        defaults.set(true, forKey: "calculatorsCollapsed")

        LearnCollapseMigration.runIfNeeded(using: defaults)

        let stored = defaults.string(forKey: "learnCollapsedSections")
        let collapsed = CollapsedSections(rawValue: stored ?? "")
        #expect(collapsed?.contains("basic-lessons") == true)
        #expect(collapsed?.contains("calculators") == true)
        #expect(defaults.object(forKey: "basicLessonsCollapsed") == nil)
        #expect(defaults.object(forKey: "calculatorsCollapsed") == nil)
    }

    @Test func runIfNeededDoesNothingWhenAlreadyMigrated() throws {
        let defaults = try makeDefaults()
        defaults.set("[\"books\"]", forKey: "learnCollapsedSections")

        LearnCollapseMigration.runIfNeeded(using: defaults)

        #expect(defaults.string(forKey: "learnCollapsedSections") == "[\"books\"]")
    }
}
