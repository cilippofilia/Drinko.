//
//  CloudSyncMerge.swift
//  DrinkoPro
//

import Foundation

/// The rules for combining a device's local values with iCloud's on that device's first sync,
/// so upgrading a second device never loses what either side had.
enum CloudSyncMerge {
    /// Whether `value` has the kind `rule` expects. Invalid iCloud values are skipped rather
    /// than written locally, e.g. data from a future app version.
    static func isValid(_ value: Any, for rule: CloudSyncedKey.Rule) -> Bool {
        switch rule {
        case .favorites: (value as? Data).flatMap(decodedFavorites) != nil
        case .recents: value is [String]
        case .setting: value is String
        }
    }

    /// The value both sides should hold after a device's first sync, or `nil` to leave both as
    /// they are (nothing on either side, or an invalid iCloud value).
    static func firstSync(local: Any?, cloud: Any?, rule: CloudSyncedKey.Rule, recentsCapacity: Int) -> Any? {
        if let cloud, !isValid(cloud, for: rule) { return nil }

        switch rule {
        case .favorites:
            return favorites(local: local as? Data, cloud: cloud as? Data)
        case .recents:
            guard local != nil || cloud != nil else { return nil }
            return recents(local: local as? [String] ?? [], cloud: cloud as? [String] ?? [], capacity: recentsCapacity)
        case .setting:
            return setting(local: local as? String, cloud: cloud as? String)
        }
    }

    /// Both favorite sets combined, encoded the way `Favorites` reads them: a JSON array of IDs,
    /// sorted so the same set always encodes to the same data. Unreadable local data counts as
    /// empty. `nil` when neither side has any.
    static func favorites(local: Data?, cloud: Data?) -> Data? {
        guard local != nil || cloud != nil else { return nil }
        let localIDs = local.flatMap(decodedFavorites) ?? []
        let cloudIDs = cloud.flatMap(decodedFavorites) ?? []
        return try? JSONEncoder().encode(localIDs.union(cloudIDs).sorted())
    }

    /// iCloud's recents first, then local ones it doesn't have, trimmed to `capacity`.
    static func recents(local: [String], cloud: [String], capacity: Int) -> [String] {
        var merged = cloud
        for id in local where !merged.contains(id) {
            merged.append(id)
        }
        return Array(merged.prefix(capacity))
    }

    /// iCloud's setting if it has one, else the local one.
    static func setting(local: String?, cloud: String?) -> String? {
        cloud ?? local
    }

    private static func decodedFavorites(_ data: Data) -> Set<String>? {
        try? JSONDecoder().decode(Set<String>.self, from: data)
    }
}
