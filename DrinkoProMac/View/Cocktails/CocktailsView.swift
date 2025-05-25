//
//  CocktailsView.swift
//  DrinkoProMac
//
//  Created by Filippo Cilia on 25/05/2025.
//

import SwiftUI

struct CocktailsView: View {
    @State private var viewModel = CocktailsViewModel()
    @State private var selectedCocktail: Cocktail?
    var favorites = Favorites()

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedCocktail) {
                ForEach(viewModel.listOfCocktails, id: \.id) { cocktail in
                    HStack {
                        if cocktail.glass == "wine" {
                            Image(systemName: "wineglass")
                                .imageScale(.large)
                                .frame(maxWidth: 45)
                        } else if cocktail.glass == "coffee mug" || cocktail.glass == "julep cup" {
                            Image("julep")
                                .resizable()
                                .scaledToFit()
                                .padding(10)
                                .frame(width: 45)
                        } else if cocktail.glass == "shot" {
                            Image("shot")
                                .resizable()
                                .scaledToFit()
                                .padding(10)
                                .frame(width: 45)
                                .scaleEffect(CGSize(width: 0.6, height: 0.6))
                        } else {
                            Image(cocktail.image)
                                .resizable()
                                .scaledToFit()
                                .padding(10)
                                .frame(width: 45)
                        }

                        Text(cocktail.name)

                        Spacer()

                        Image(systemName: favorites.contains(cocktail) ? "heart.fill" : "heart")
                            .foregroundColor(favorites.contains(cocktail) ? Color.red : Color.clear)
                            .animation(.default, value: favorites.hasEffect)
                            .symbolEffect(.bounce.up, value: favorites.hasEffect)
                    }
                    .frame(height: 45)
                    .tag(cocktail)
                    .contentShape(Rectangle())
                }
            }
        } detail: {
            if let cocktail = selectedCocktail {
                Text(cocktail.name)
            } else {
                UnselectedView(
                    image: "wineglass.fill",
                    title: "Welcome to Drinko Cocktails",
                    subtitle: "Select a cocktail from the sidebar to get started."
                )
            }
        }
    }
}

#Preview {
    CocktailsView()
}
