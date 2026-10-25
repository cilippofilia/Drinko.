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
        /// The cocktail isn't bundled, so it is being downloaded.
        case loading
        case cocktail(ClipCocktail)
        case missing
    }

    private(set) var content: Content = .waiting
    private let bundled: BundledCocktailCatalog
    private let fetchRemote: @Sendable () async -> BundledCocktailCatalog?
    /// Counts links, so a download that finishes after a newer link was opened is ignored.
    private var generation = 0

    init(
        bundled: BundledCocktailCatalog = .load(),
        fetchRemote: @escaping @Sendable () async -> BundledCocktailCatalog? = { await RemoteCocktailCatalog.live() }
    ) {
        self.bundled = bundled
        self.fetchRemote = fetchRemote
    }

    /// Shows a bundled cocktail at once and refreshes it from GitHub, or downloads one that isn't bundled.
    func open(_ url: URL) async {
        generation += 1
        let current = generation
        guard let id = CocktailClipLink.cocktailID(from: url) else {
            content = .missing
            return
        }
        let bundledHit = ClipCocktail(id: id, in: bundled)
        content = bundledHit.map(Content.cocktail) ?? .loading

        let remote = await fetchRemote()
        guard current == generation else { return }
        let remoteHit = remote.flatMap { ClipCocktail(id: id, in: $0) }
        if let remoteHit {
            if remoteHit != bundledHit { content = .cocktail(remoteHit) }
        } else if bundledHit == nil {
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
