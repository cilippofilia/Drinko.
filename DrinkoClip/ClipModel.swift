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

    /// Shows the cocktail the invocation URL names, or the missing state for anything else.
    func open(_ url: URL) {
        if let id = CocktailClipLink.cocktailID(from: url), let cocktail = catalog.cocktail(withID: id) {
            content = .cocktail(cocktail)
        } else {
            content = .missing
        }
    }

    /// Falls back to the missing state when no link arrived, so a bare launch never waits forever.
    /// Does nothing once a link has been opened.
    func showMissingIfStillWaiting() {
        if content == .waiting {
            content = .missing
        }
    }
}
