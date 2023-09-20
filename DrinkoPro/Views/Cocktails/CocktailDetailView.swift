//
//  CocktailDetailView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 23/04/2023.
//

import SwiftUI

struct CocktailDetailView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.horizontalSizeClass) var sizeClass
    
    @ObservedObject var favorites = Favorites()

    @State private var showHistory = false
    @State private var selectedUnit = "oz."
    @State private var frameHeight: CGFloat = 280
    @State private var corners: CGFloat = 10

    var units = ["oz.", "ml"]
    var cocktail: Cocktail

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            if sizeClass == .compact {
                compactDetailView
            } else {
                regularDetailView
            }
        }
        .navigationTitle(cocktail.name)
            // forcing displayMode .inline to avoid cropping the back bar button - this way will be standardized between 'Cocktails' and 'Back' if the Navigation Title is too long
        .navigationBarTitleDisplayMode(.inline)
    }

    var compactDetailView: some View {
        VStack {
            AsyncImage(url: URL(string: cocktail.pic)) { phase in
                switch phase {
                    case .failure:
                        failure

                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()

                    default:
                        ProgressView()
                }
            }
            .frame(width: compactScreenWidth,
                   height: frameHeight)
            .background(Color.white)
            .cornerRadius(corners)

            VStack(alignment: .leading) {
                Text(cocktail.name)
                    .font(.title.bold())

                Picker("Select unit", selection: $selectedUnit) {
                    ForEach(units, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: compactScreenWidth / 2)
                .frame(maxWidth: .infinity, alignment: .center)


                CocktailDetailSectionView(cocktail: cocktail,
                                          text: "Ingredients")

                ForEach(cocktail.ingredients) { ingredient in
                    HStack {
                            // "%2g" reduces the decimal points to 2 digits
                        Text(selectedUnit == "oz." ?
                             "\(ingredient.quantity, specifier: "%2g")" :
                                "\(ingredient.mlQuantity, specifier: "%2g")")

                        Text(selectedUnit == "oz." ?
                             ingredient.unit :
                                ingredient.mlUnit)

                        Text(ingredient.name.capitalized)

                        Spacer()
                    }
                    .multilineTextAlignment(.leading)
                }

                CocktailDetailSectionView(cocktail: cocktail,
                                          text: "Method")

                CocktailDetailSectionView(cocktail: cocktail,
                                          text: "Glass")

                CocktailDetailSectionView(cocktail: cocktail,
                                          text: "Garnish")

                CocktailDetailSectionView(cocktail: cocktail,
                                          text: "Ice")

                CocktailDetailSectionView(cocktail: cocktail,
                                          text: "Extra")


                HStack {
                        // HISTORY BUTTON
                    if cocktail.history != "" {
                        DrinkoButtonView(title: "History",
                                         icon: "book.fill",
                                         background: .blue,
                                         foreground: .white) {
                            showHistory.toggle()
                        }
                                         .sheet(isPresented: $showHistory) {
                                             HistoryView(cocktail: cocktail)
                                                 .presentationDetents([.large,.fraction(0.75)])
                                         }
                    }
                        // ADD TO FAV BUTTON
                    if cocktail.history.isEmpty {
                        DrinkoButtonView(title: "Like",
                                         icon: favorites.contains(cocktail) ? "heart.slash.fill" : "heart.fill",
                                         background: favorites.contains(cocktail) ? .red : .blue,
                                         foreground: .white,
                                         handler: {
                            if favorites.contains(cocktail) {
                                favorites.remove(cocktail)
                            } else {
                                favorites.add(cocktail)
                                    // haptic feedback
                                UINotificationFeedbackGenerator()
                                    .notificationOccurred(.success)
                            }
                        })
                        .frame(maxWidth: .infinity)
                    } else {
                        DrinkoButtonView(title: "Like",
                                         icon: favorites.contains(cocktail) ? "heart.slash.fill" : "heart.fill",
                                         background: favorites.contains(cocktail) ? .red : .blue,
                                         foreground: .white,
                                         handler: {
                            if favorites.contains(cocktail) {
                                favorites.remove(cocktail)
                            } else {
                                favorites.add(cocktail)
                                    // haptic feedback
                                UINotificationFeedbackGenerator()
                                    .notificationOccurred(.success)
                            }
                        })
                        .frame(maxWidth: 120)
                    }
                }
                .padding(.vertical)
            }
        }
        .frame(width: compactScreenWidth)
    }

    var regularDetailView: some View {
        VStack {
            AsyncImage(url: URL(string: cocktail.pic)) { phase in
                switch phase {
                    case .failure:
                        failure

                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()

                    default:
                        ProgressView()
                }
            }
            .frame(width: regularScreenWidth,
                   height: frameHeight * 1.75)
            .background(Color.white)
            .cornerRadius(corners * 1.75)

            VStack(spacing: 10) {
                HStack {
                    Text(cocktail.name)
                        .font(.title.bold())

                    Spacer()

                    DrinkoButtonView(title: "Like",
                                     icon: favorites.contains(cocktail) ? "heart.slash.fill" : "heart.fill",
                                     background: favorites.contains(cocktail) ? .red : .blue,
                                     foreground: .white,
                                     handler: {
                        if favorites.contains(cocktail) {
                            favorites.remove(cocktail)
                        } else {
                            favorites.add(cocktail)
                                // haptic feedback
                            UINotificationFeedbackGenerator()
                                .notificationOccurred(.success)
                        }
                    })
                    .frame(maxWidth: frameHeight)
                }
                .padding(.vertical)

                Picker("Select unit", selection: $selectedUnit) {
                    ForEach(units, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: regularScreenWidth / 2)
                .frame(maxWidth: .infinity, alignment: .center)

                CocktailDetailSectionView(cocktail: cocktail,
                                          text: "Ingredients")

                ForEach(cocktail.ingredients) { ingredient in
                    HStack {
                            // "%2g" reduces the decimal points to 2 digits
                        Text(selectedUnit == "oz." ?
                             "\(ingredient.quantity, specifier: "%2g")" :
                                "\(ingredient.mlQuantity, specifier: "%2g")")

                        Text(selectedUnit == "oz." ?
                             ingredient.unit :
                                ingredient.mlUnit)

                        Text(ingredient.name.capitalized)

                        Spacer()
                    }
                    .multilineTextAlignment(.leading)
                }

                CocktailDetailSectionView(cocktail: cocktail,
                                          text: "Method")

                CocktailDetailSectionView(cocktail: cocktail,
                                          text: "Glass")

                CocktailDetailSectionView(cocktail: cocktail,
                                          text: "Garnish")

                CocktailDetailSectionView(cocktail: cocktail,
                                          text: "Ice")

                CocktailDetailSectionView(cocktail: cocktail,
                                          text: "Extra")

                HistoryView(cocktail: cocktail)
            }
            .frame(width: regularScreenWidth)
        }
    }

    var failure: some View {
        VStack(spacing: 10) {
            Image(systemName: "icloud.slash.fill")
                .font(.largeTitle)
            Text("Couldn't load image")
                .font(.headline)
        }
        .foregroundColor(.gray)
    }
}

#Preview {
//    TabView {
        NavigationStack {
            CocktailDetailView(cocktail: .example)
                .environmentObject(Favorites())
                .preferredColorScheme(.dark)
        }
//    }
}
