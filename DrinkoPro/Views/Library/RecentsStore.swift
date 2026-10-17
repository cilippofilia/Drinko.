//
//  RecentsStore.swift
//  DrinkoPro
//

import Foundation
import Observation

@MainActor
@Observable
final class RecentsStore {
    enum Namespace: String, CaseIterable {
        case learn
        case cocktails
    }

    static let capacity = 9

    /// How long a selection must stay put before it's recorded, so quickly moving through
    /// selections doesn't record each one.
    static let recordDelay: Duration = .seconds(1)

    @ObservationIgnored private let defaults: UserDefaults
    private var idsByNamespace: [Namespace: [String]] = [:]

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        reload()
    }

    /// For changes from iCloud.
    func reload() {
        for namespace in Namespace.allCases {
            let stored = defaults.stringArray(forKey: Self.storageKey(for: namespace)) ?? []
            idsByNamespace[namespace] = Array(stored.prefix(Self.capacity))
        }
    }

    /// Newest first.
    func ids(in namespace: Namespace) -> [String] {
        idsByNamespace[namespace] ?? []
    }

    func record(_ id: String, in namespace: Namespace) {
        var ids = ids(in: namespace)
        ids.removeAll { $0 == id }
        ids.insert(id, at: 0)
        ids = Array(ids.prefix(Self.capacity))
        idsByNamespace[namespace] = ids
        defaults.set(ids, forKey: Self.storageKey(for: namespace))
    }

    func remove(_ id: String, in namespace: Namespace) {
        var ids = ids(in: namespace)
        ids.removeAll { $0 == id }
        idsByNamespace[namespace] = ids
        defaults.set(ids, forKey: Self.storageKey(for: namespace))
    }

    /// Also synced to iCloud by `CloudSync`.
    nonisolated static func storageKey(for namespace: Namespace) -> String {
        "recents.\(namespace.rawValue)"
    }
}
