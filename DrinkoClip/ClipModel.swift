//
//  ClipModel.swift
//  DrinkoClip
//

import Foundation
import Observation

/// What the App Clip is showing: the cocktail named by the link it was opened with.
@MainActor
@Observable
final class ClipModel {
    enum Content: Equatable {
        /// Opened without a link yet (e.g. launched from Xcode without `_XCAppClipURL`).
        case waiting
        case cocktail(Cocktail)
        case missing
    }

    private(set) var content: Content = .waiting
    let catalog = BundledCocktailCatalog.load()

    func open(_ url: URL) {
        if let id = CocktailClipLink.cocktailID(from: url), let cocktail = catalog.cocktail(withID: id) {
            content = .cocktail(cocktail)
        } else {
            content = .missing
        }
    }

    /// Falls back to the missing state when no link arrived, so a bare launch never waits forever.
    func showMissingIfStillWaiting() {
        if content == .waiting {
            content = .missing
        }
    }
}
