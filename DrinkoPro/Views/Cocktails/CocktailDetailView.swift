//
//  CocktailDetailView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 23/04/2023.
//

import SwiftUI

struct CocktailDetailView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var favorites = Favorites()

    @State private var showHistory = false
    @State private var selectedUnit = "oz."
    var units = ["oz.", "ml"]
    
    var cocktail: Cocktail

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading) {
                    Text(cocktail.name)
                        .font(.title)
                        .bold()

                    Picker("Select unit", selection: $selectedUnit) {
                        ForEach(units, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: screenWidthPlusMargins / 2)
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
                            Button(action: {
                                showHistory.toggle()
                            }) {
                                DrinkoLabelWithText(symbolName: "book.fill",
                                                  text: "History",
                                                  color: .white,
                                                  background: .blue)
                            }
                            .sheet(isPresented: $showHistory) {
                                HistoryView(cocktail: cocktail)
                                    .presentationDetents([.large,.fraction(0.75)])
                            }
                        }
                        // ADD TO FAV BUTTON
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
                            DrinkoLabel(symbolName: favorites.contains(cocktail) ?
                                        "heart.slash.fill" : "heart.fill",
                                        color: .white,
                                        background: favorites.contains(cocktail) ?
                                        .red : .blue)
                                .frame(width: 60)
                        }
                    }
                    .padding(.vertical)
                }
                .frame(width: screenWidthPlusMargins)
            }
            .navigationTitle(cocktail.name)
            // forcing displayMode .inline to avoid cropping the back bar button - this way will be standardized between 'Cocktails' and 'Back' if the Navigation Title is too long
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#if DEBUG
struct CocktailDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CocktailDetailView(cocktail: .example)
            .environmentObject(Favorites())
    }
}
#endif
