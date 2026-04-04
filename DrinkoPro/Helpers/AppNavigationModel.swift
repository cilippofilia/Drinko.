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
    var selectedTab: String?
    var pendingCocktailID: String?

    func handle(url: URL) {
        guard url.scheme == "drinko" else { return }
        guard url.host == "cocktail" else { return }

        let pathComponents = url.pathComponents.filter { $0 != "/" }
        guard let cocktailID = pathComponents.first, !cocktailID.isEmpty else { return }

        selectedTab = CocktailsView.cocktailsTag
        pendingCocktailID = cocktailID
    }

    func consumePendingCocktailID() -> String? {
        defer { pendingCocktailID = nil }
        return pendingCocktailID
    }
}
