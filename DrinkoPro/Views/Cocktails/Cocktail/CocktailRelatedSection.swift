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
    let procedure: Procedure

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
        }
        .padding(.vertical)
    }
}

#if DEBUG
#Preview {
    CocktailRelatedSection(cocktail: .example, procedure: .example)
        .environment(CocktailsViewModel())
}
#endif
