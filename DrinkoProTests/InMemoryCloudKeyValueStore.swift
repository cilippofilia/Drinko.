import Foundation
@testable import DrinkoPro

/// A `CloudKeyValueStore` that keeps values in memory and records which keys were written.
@MainActor
final class InMemoryCloudKeyValueStore: CloudKeyValueStore {
    var values: [String: Any] = [:]
    var writes: [String] = []

    func object(forKey key: String) -> Any? {
        values[key]
    }

    func set(_ value: Any?, forKey key: String) {
        values[key] = value
        writes.append(key)
    }

    func synchronize() -> Bool {
        true
    }
}
