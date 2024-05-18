//
//  CocktailsView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 22/04/2023.
//

import SwiftUI
import TipKit

struct CocktailsView: View {
    static let cocktailsTag: String? = "Cocktails"
    
    @Environment(\.horizontalSizeClass) var sizeClass
    @State private var viewModel = CocktailsViewModel()
    @State private var showingSortOrder = false
    @State var path = NavigationPath()

    var favorites = Favorites()
    var favoriteCocktailsTip = SwipeToFavoriteTip()

    var body: some View {
        NavigationStack(path: $path) {
            List(viewModel.filteredCocktails) { cocktail in
                NavigationLink(value: cocktail) {
                    CocktailRowView(favorites: favorites, cocktail: cocktail)
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            FavoriteCocktailButtonView(favorites: favorites, cocktail: cocktail)
                                .tint(favorites.contains(cocktail) ? .red : .blue)
                        }
                }
            }
            .popoverTip(favoriteCocktailsTip)
            .navigationTitle("Cocktails")
            .navigationDestination(for: Cocktail.self) { cocktail in
                CocktailDetailView(favorites: favorites, cocktail: cocktail)
            }
            .searchable(text: $viewModel.searchText, prompt: "Search Cocktails")
            .toolbar {
                sortButtonToolbarItem
            }
            .task {
                try? Tips.configure([
                    .displayFrequency(.immediate),
                    .datastoreLocation(.applicationDefault)
                ])
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

private extension CocktailsView {
    var sortButtonToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                showingSortOrder.toggle()
            } label: {
                if UIAccessibility.isVoiceOverRunning {
                    Text("Sort cocktails")
                } else {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                }
            }
            .confirmationDialog(
                "Sort cocktails",
                isPresented: $showingSortOrder
            ) {
                Button("A -> Z") {
                    viewModel.sortOption = .fromAtoZ
                }
                Button("Z -> A") {
                    viewModel.sortOption = .fromZtoA
                }
                Button("By Glass") {
                    viewModel.sortOption = .byGlass
                }
                Button("By Ice") {
                    viewModel.sortOption = .byIce
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        CocktailsView()
    }
}
#endif
