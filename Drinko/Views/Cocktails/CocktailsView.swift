//
//  CocktailsView.swift
//  Drinko
//
//  Created by Filippo Cilia on 22/04/2023.
//

import SwiftUI

struct CocktailsView: View {
    @StateObject var favorites = Favorites()
    static let cocktailsTag: String? = "Cocktails"

    @State private var searchText = ""

    let categories = Bundle.main.decode([Category].self, from: "cocktails.json")

    var body: some View {
        NavigationStack {
            List(categories) { category in
                ForEach(category.cocktails) { cocktail in
                    // When dealing with favorites, it is important to pass the favorite through although is not required from swift and would actually still compile
                    if searchText.isEmpty || cocktail.contains(searchText) {
                        CocktailRowView(favorites: favorites, category: category, cocktail: cocktail)
                            .contextMenu {
                                Button(action: {
                                    if favorites.contains(cocktail) {
                                        favorites.remove(cocktail)

                                    } else {
                                        favorites.add(cocktail)

                                        // haptic feedback
                                        UINotificationFeedbackGenerator()
                                            .notificationOccurred(.success)
                                    }
                                }) {
                                    Image(systemName: "heart")
                                    // Deep press-Context button text
                                    Text(favorites.contains(cocktail) ? "Remove from favorites" : "Add to favorites")
                                }
                            }
                    }
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("Cocktails")
        }
        .environmentObject(favorites)
    }
}

struct CocktailsView_Previews: PreviewProvider {
    static var previews: some View {
        CocktailsView()
    }
}
