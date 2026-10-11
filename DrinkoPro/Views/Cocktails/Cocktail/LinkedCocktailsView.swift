//
//  LinkedCocktailsView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 25/05/2025.
//

import SwiftUI

struct LinkedCocktailsView: View {
    @Environment(CocktailsViewModel.self) private var viewModel

    let cocktails: [Cocktail]

    var body: some View {
        // Spaced and divided like the procedure steps, so every card reads the same.
        VStack(alignment: .leading, spacing: detailCardGroupSpacing) {
            ForEach(cocktails) { cocktail in
                NavigationLink(value: cocktail) {
                    // The same sticker row as the Cocktails list layout. The card already insets
                    // it, so skip the row's own padding.
                    LibraryRowView(model: viewModel.cardModel(for: cocktail), padsEdges: false)
                }
                .buttonStyle(.plain)

                if cocktail.id != cocktails.last?.id {
                    Divider()
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    LinkedCocktailsView(cocktails: [.example])
        .environment(CocktailsViewModel())
}
#endif
