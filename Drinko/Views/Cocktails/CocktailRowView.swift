//
//  CocktailRowView.swift
//  Drinko
//
//  Created by Filippo Cilia on 23/04/2023.
//

import SwiftUI

struct CocktailRowView: View {
    @ObservedObject var favorites = Favorites()

    var cocktail: Cocktail

    var body: some View {
        NavigationLink(destination: CocktailDetailView(cocktail: cocktail)) {
            HStack(spacing: 10) {
                if cocktail.glass == "wine" {
                    Image(systemName: "wineglass")
                        .imageScale(.large)
                        .frame(maxWidth: 45)

                } else if cocktail.glass == "coffee mug" || cocktail.glass == "julep cup"{
                    Image("julep")
                        .resizable()
                        .scaledToFit()
                        .padding(10)
                        .frame(width: 45)
                } else {
                    Image(cocktail.image)
                        .resizable()
                        .scaledToFit()
                        .padding(10)
                        .frame(width: 45)
                }

                Text(cocktail.name)

                Spacer()

                withAnimation(.easeInOut(duration: 0.5)) {
                    Image(systemName: favorites.contains(cocktail) ? "heart.fill" : "heart")
                        .foregroundColor(.red)
                        .opacity(favorites.contains(cocktail) ? 1 : 0)
                }
            }
            .frame(height: 45)
        }
        .environmentObject(favorites)
    }
}

struct CocktailRowView_Previews: PreviewProvider {
    static var previews: some View {
        CocktailRowView(cocktail: .example)
    }
}
