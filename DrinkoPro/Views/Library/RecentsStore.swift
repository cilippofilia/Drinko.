//
//  RecentsStore.swift
//  DrinkoPro
//

import Foundation
import Observation

/// Remembers the most recently opened library items for each library screen.
@MainActor
@Observable
final class RecentsStore {
    enum Namespace: String, CaseIterable {
        case learn
        case cocktails
    }

    /// How many recent items each namespace keeps.
    static let capacity = 9

    @ObservationIgnored private let defaults: UserDefaults
    private var idsByNamespace: [Namespace: [String]] = [:]

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        for namespace in Namespace.allCases {
            let stored = defaults.stringArray(forKey: Self.key(for: namespace)) ?? []
            idsByNamespace[namespace] = Array(stored.prefix(Self.capacity))
        }
    }

    /// Recent IDs for `namespace`, newest first.
    func ids(in namespace: Namespace) -> [String] {
        idsByNamespace[namespace] ?? []
    }

    /// Moves `id` to the front of `namespace`, removing duplicates and trimming to `capacity`.
    func record(_ id: String, in namespace: Namespace) {
        var ids = ids(in: namespace)
        ids.removeAll { $0 == id }
        ids.insert(id, at: 0)
        ids = Array(ids.prefix(Self.capacity))
        idsByNamespace[namespace] = ids
        defaults.set(ids, forKey: Self.key(for: namespace))
    }

    /// Removes `id` from `namespace`, if present. Used e.g. when a user-created item is deleted.
    func remove(_ id: String, in namespace: Namespace) {
        var ids = ids(in: namespace)
        ids.removeAll { $0 == id }
        idsByNamespace[namespace] = ids
        defaults.set(ids, forKey: Self.key(for: namespace))
    }

    private static func key(for namespace: Namespace) -> String {
        "recents.\(namespace.rawValue)"
    }
}
