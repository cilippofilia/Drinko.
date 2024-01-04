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
    
    @State private var histories: [History] = Bundle.main.decode([History].self, from: "history.json")
    
    @State private var showHistory = false
    @State private var showProcedure = false

    @State private var selectedUnit = "oz."
    @State private var frameSize: CGFloat = 280
    @State private var corners: CGFloat = 10

    var units = ["oz.", "ml"]
    var cocktail: Cocktail
    var cocktailHistory: History? {
        return histories.first(where: { $0.id == cocktail.id } )
    }

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
                        imageFailedToLoad

                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()

                    default:
                        ProgressView()
                }
            }
            .frame(width: compactScreenWidth,
                   height: frameSize)
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

                HStack(spacing: 10) {
                    if (cocktailHistory?.text ?? "") != "" {
                        // HISTORY BUTTON
                        DrinkoButtonView(title: "History",
                                         icon: "book.fill",
                                         background: .blue,
                                         foreground: .white) {
                            showHistory.toggle()
                        }
                                         .sheet(isPresented: $showHistory) {
                                             HistoryView(cocktail: cocktail, history: cocktailHistory!)
                                                 .presentationDetents([.large,.fraction(0.75)])
                                         }
                    } 
                    
                    if (cocktailHistory?.text ?? "") == "" {
                        DrinkoButtonView(title: "Procedure",
                                         icon: "list.clipboard.fill",
                                         background: .blue,
                                         foreground: .white) {
                            showProcedure.toggle()
                        }
                                         .sheet(isPresented: $showProcedure) {
                                             ProcedureView(procedure: "Procedure")
                                                 .presentationDetents([.large,.fraction(0.75)])
                                         }
                    }
                    
                    // ADD TO FAV BUTTON
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
                    .frame(maxWidth: (cocktailHistory?.text ?? "") != "" ? frameSize / 2 : .infinity)
                }
                .padding(.vertical)
                
                if (cocktailHistory?.text ?? "") != "" {
                    DrinkoButtonView(title: "Procedure",
                                     icon: "list.clipboard.fill",
                                     background: .blue,
                                     foreground: .white) {
                        showProcedure.toggle()
                    }
                                     .sheet(isPresented: $showProcedure) {
                                         ProcedureView(procedure: "Procedure")
                                             .presentationDetents([.large,.fraction(0.75)])
                                     }
                }
            }
            Spacer(minLength: 50)
        }
        .frame(width: compactScreenWidth)
    }

    var regularDetailView: some View {
        VStack {
            AsyncImage(url: URL(string: cocktail.pic)) { phase in
                switch phase {
                    case .failure:
                        imageFailedToLoad

                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()

                    default:
                        ProgressView()
                }
            }
            .frame(width: regularScreenWidth,
                   height: frameSize * 1.75)
            .background(Color.white)
            .cornerRadius(corners * 1.75)

            VStack(spacing: 20) {
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
                    .frame(maxWidth: frameSize / 1.75 )
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

                ProcedureView(procedure: "Procedure")
                
                if (cocktailHistory?.text ?? "") != "" {
                    HistoryView(cocktail: cocktail, history: cocktailHistory!)
                }
                
                Spacer(minLength: 50)
            }
            .frame(width: regularScreenWidth)
        }
    }
}

#if DEBUG
#Preview {
    TabView {
        NavigationStack {
            CocktailDetailView(cocktail: .example)
                .environmentObject(Favorites())
                .preferredColorScheme(.dark)
        }
    }
}
#endif
