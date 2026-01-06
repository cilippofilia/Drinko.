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

    var body: some View {
        Group {
            ForEach(cocktails) { cocktail in
                NavigationLink(value: cocktail) {
                    HStack {
                        CocktailRowView(
                            cocktail: cocktail
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

#if DEBUG
#Preview {
    LinkedCocktailsView(cocktails: [], procedure: nil)
}
#endif
