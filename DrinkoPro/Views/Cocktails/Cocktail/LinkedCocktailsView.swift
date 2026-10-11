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
        Group {
            ForEach(cocktails) { cocktail in
                NavigationLink(value: cocktail) {
                    // The same sticker row as the Cocktails list layout. The card already insets
                    // it, so skip the row's side padding.
                    LibraryRowView(model: viewModel.cardModel(for: cocktail), padsHorizontalEdges: false)
                }
                .buttonStyle(.plain)
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
