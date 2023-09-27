//
//  CocktailRowView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 23/04/2023.
//

import SwiftUI

struct CocktailRowView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @ObservedObject var favorites = Favorites()
    
    @State private var frameSize: CGFloat = 45

    var cocktail: Cocktail

    var body: some View {
        NavigationLink(destination: CocktailDetailView(favorites: favorites, cocktail: cocktail)) {
            HStack(spacing: sizeClass == .compact ? 10 : 20) {
                if cocktail.glass == "wine" {
                    Image(systemName: "wineglass")
                        .imageScale(.large)
                        .frame(maxWidth: frameSize)

                } else if cocktail.glass == "coffee mug" || cocktail.glass == "julep cup"{
                    Image("julep")
                        .resizable()
                        .scaledToFit()
                        .padding(10)
                        .frame(width: frameSize)
                } else {
                    Image(cocktail.image)
                        .resizable()
                        .scaledToFit()
                        .padding(10)
                        .frame(width: frameSize)
                }

                Text(cocktail.name)

                Spacer()

                if favorites.contains(cocktail) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        Image(systemName: favorites.contains(cocktail) ? "heart.fill" : "heart")
                            .foregroundColor(.red)
                            .opacity(favorites.contains(cocktail) ? 1 : 0)
                    }
                }
            }
        }
        .frame(height: frameSize)
    }
}

#Preview {
    CocktailRowView(cocktail: .example)
        .environmentObject(Favorites())
}
