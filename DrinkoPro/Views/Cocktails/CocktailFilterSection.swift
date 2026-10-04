//
//  CocktailFilterSection.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 04/10/2026.
//

import SwiftUI

/// The "Filter" section of the Cocktails options menu. Only lists filters
/// that can return results for the current list source.
struct CocktailFilterSection: View {
    @Binding var filterOption: CocktailsViewModel.FilterOption
    let availableOptions: [CocktailsViewModel.FilterOption]

    var body: some View {
        Section("Filter") {
            ForEach(availableOptions, id: \.self) { option in
                Button {
                    filterOption = option
                } label: {
                    HStack {
                        Text(title(for: option))
                        if filterOption == option {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }
    }

    private func title(for option: CocktailsViewModel.FilterOption) -> LocalizedStringKey {
        switch option {
        case .all:
            "All Cocktails"
        case .cocktailsOnly:
            "Cocktails Only"
        case .shotsOnly:
            "Shots Only"
        case .favoritesOnly:
            "Favorites Only"
        case .userCreatedOnly:
            "User Created Only"
        }
    }
}
