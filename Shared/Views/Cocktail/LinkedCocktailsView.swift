//
//  LinkedCocktailsView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 25/05/2025.
//

import SwiftUI

struct LinkedCocktailsView: View {
    let cocktails: [Cocktail]
    let procedure: Procedure?
    let favorites: Favorites

    var body: some View {
        Group {
            ForEach(cocktails) { cocktail in
                NavigationLink(value: cocktail) {
                    HStack {
                        CocktailRowView(
                            cocktail: cocktail,
                            favorites: favorites
                        )

                        Image(systemName: "chevron.right")
                            .bold()
                            .imageScale(.small)
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    LinkedCocktailsView(cocktails: [], procedure: nil, favorites: Favorites())
}
