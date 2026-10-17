//
//  CocktailsOptionsMenu.swift
//  DrinkoPro
//

import SwiftUI

struct CocktailsOptionsMenu: View {
    @Environment(CocktailsViewModel.self) private var viewModel

    @Binding var filterOption: CocktailsViewModel.FilterOption
    /// A fixed filter for the page; the filter section is hidden when set.
    let presetFilter: CocktailsViewModel.FilterOption?
    let availableOptions: [CocktailsViewModel.FilterOption]

    var body: some View {
        @Bindable var viewModel = viewModel

        Menu {
            if presetFilter == nil {
                CocktailFilterSection(
                    filterOption: $filterOption,
                    availableOptions: availableOptions
                )
            }

            Section("Sort") {
                Picker("Sort", selection: $viewModel.sortOption) {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Text(option.title).tag(option)
                    }
                }
                .pickerStyle(.inline)
            }
        } label: {
            Label("Filter and Sort", systemImage: "line.3.horizontal.decrease.circle")
        }
    }
}
