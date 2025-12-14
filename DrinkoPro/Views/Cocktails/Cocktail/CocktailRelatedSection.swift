//
//  CocktailRelatedSection.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 14/12/2024.
//

import SwiftUI

struct CocktailRelatedSection: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(CocktailsViewModel.self) private var viewModel
    let cocktail: Cocktail
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let procedure = viewModel.getCocktailProcedure(for: cocktail) {
                ProcedureView(
                    cocktail: cocktail,
                    procedure: procedure
                )
            }

            if !viewModel.getLinkedCocktails(for: cocktail).isEmpty {
                Text("You may also like")
                    .font(sizeClass == .compact ? .title3.bold() : .title.bold())
                    .padding(.vertical)

                LinkedCocktailsView(
                    cocktails: viewModel.getLinkedCocktails(for: cocktail),
                    procedure: viewModel.getCocktailProcedure(for: cocktail)
                )
            }
        }
        .padding(.vertical)
    }
}

#if DEBUG
#Preview {
    CocktailRelatedSection(cocktail: .example)
        .environment(CocktailsViewModel())
}
#endif
