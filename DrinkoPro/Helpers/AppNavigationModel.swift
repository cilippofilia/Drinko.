//
//  AppNavigationModel.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 04/04/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class AppNavigationModel {
    var selectedTab: AppTab = .learn
    var pendingCocktailID: String?

    /// A "New…" menu command waiting for the page that owns its sheet to present it.
    enum CreationRequest: Equatable {
        case cocktail
        case category
    }

    var pendingCreation: CreationRequest?

    func handle(url: URL) {
        guard url.scheme == "drinko" else { return }
        guard url.host == "cocktail" else { return }

        let pathComponents = url.pathComponents.filter { $0 != "/" }
        guard let cocktailID = pathComponents.first, !cocktailID.isEmpty else { return }

        selectedTab = .cocktails
        pendingCocktailID = cocktailID
    }

    func consumePendingCocktailID() -> String? {
        defer { pendingCocktailID = nil }
        return pendingCocktailID
    }

    /// File › New Cocktail. Stays on the current page when it's already a Cocktails page
    /// (every one has a Create Cocktail button), otherwise opens the main Cocktails page.
    func requestNewCocktail() {
        if selectedTab.parent != .cocktails {
            selectedTab = .cocktails
        }
        pendingCreation = .cocktail
    }

    /// File › New Category. Only the main Cabinet page has the Add Category sheet.
    func requestNewCategory() {
        selectedTab = .cabinet
        pendingCreation = .category
    }

    /// Clears and returns `true` if `request` is the pending one; otherwise leaves it alone.
    func consumePendingCreation(_ request: CreationRequest) -> Bool {
        guard pendingCreation == request else { return false }
        pendingCreation = nil
        return true
    }
}
