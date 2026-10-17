//
//  ClipMissingCocktailView.swift
//  DrinkoClip
//

import SwiftUI

/// Shown when the link doesn't name a cocktail this version of Drinko knows.
struct ClipMissingCocktailView: View {
    var body: some View {
        ContentUnavailableView(
            "Cocktail Unavailable",
            systemImage: "wineglass",
            description: Text("Get Drinko to browse every recipe.")
        )
    }
}
