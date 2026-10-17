//
//  CollapsedSections.swift
//  DrinkoPro
//

import Foundation

struct CollapsedSections: RawRepresentable, Equatable {
    static let learnStorageKey = "learnCollapsedSections"

    static let cocktailsStorageKey = "cocktailsCollapsedSections"

    private var ids: Set<String>

    init() {
        ids = []
    }

    /// Invalid data yields an empty set rather than failing.
    init?(rawValue: String) {
        let decoded = try? JSONDecoder().decode(Set<String>.self, from: Data(rawValue.utf8))
        ids = decoded ?? []
    }

    var rawValue: String {
        guard let data = try? JSONEncoder().encode(ids.sorted()) else { return "[]" }
        return String(decoding: data, as: UTF8.self)
    }

    func contains(_ id: String) -> Bool {
        ids.contains(id)
    }

    /// Searching always shows every section expanded.
    func isCollapsed(_ id: String, whileSearching isSearching: Bool) -> Bool {
        !isSearching && contains(id)
    }

    mutating func toggle(_ id: String) {
        if ids.contains(id) {
            ids.remove(id)
        } else {
            ids.insert(id)
        }
    }
}
