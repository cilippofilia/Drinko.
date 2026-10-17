//
//  CloudKeyValueStore.swift
//  DrinkoPro
//

import Foundation

/// The parts of `NSUbiquitousKeyValueStore` that `CloudSync` uses, so tests can use an
/// in-memory store. There's no remove: values removed locally stay in iCloud, so a reset on
/// one device can't wipe the others.
@MainActor
protocol CloudKeyValueStore: AnyObject {
    func object(forKey key: String) -> Any?
    func set(_ value: Any?, forKey key: String)
    @discardableResult func synchronize() -> Bool
}

extension NSUbiquitousKeyValueStore: CloudKeyValueStore {}
