//
//  ContentSource.swift
//  DrinkoPro
//

import Foundation

/// Where the content on screen came from. Shown in a debug-only Settings footer.
enum ContentSource: Equatable, Sendable {
    /// No cache yet: the JSON bundled with the app.
    case bundled
    /// The on-device cache, last confirmed up to date at `checkedAt`.
    case cached(checkedAt: Date)
    /// Downloaded from GitHub during this launch.
    case fetched(at: Date)
}
