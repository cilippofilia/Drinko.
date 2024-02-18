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
    @State private var procedures: [Procedure] = Bundle.main.decode([Procedure].self, from: "procedure.json")
    
    @State private var showHistory = false
    @State private var showProcedure = false

    @State private var selectedUnit = "ml"
    var units = ["ml", "oz."]

    @State private var frameSize: CGFloat = 280
    @State private var corners: CGFloat = 10

    let cocktail: Cocktail
    var cocktailHistory: History? {
        return histories.first(where: { $0.id == cocktail.id })
    }
    var cocktailProcedure: Procedure? {
        return procedures.first(where: { cocktail.id == $0.id })
    }

    var body: some View {
        ScrollView {
            if sizeClass == .compact {
                compactDetailView
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            likeButton
                        }
                    }
            } else {
                regularDetailView
            }
        }
        .navigationTitle(cocktail.name)
        // forcing displayMode .inline to avoid cropping the back bar button - this way will be standardised between 'Cocktails' and 'Back' if the Navigation Title is too long
        .navigationBarTitleDisplayMode(.inline)
        .scrollIndicators(.hidden, axes: .vertical)
        .scrollBounceBehavior(.basedOnSize)
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
                .padding(.bottom)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 10) {
                    CocktailDetailSectionView(cocktail: cocktail,
                                              text: "Ingredients")
                    
                    ingredientsView
                    
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
                }
                .padding(.vertical)
                
                Divider()

                VStack {
                    ProcedureView(cocktail: cocktail,
                                  procedure: cocktailProcedure!)
                    
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
                    }
                    .padding(.vertical)
                }
                .padding(.top)
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

                ingredientsView

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
                
                ProcedureView(cocktail: cocktail, procedure: cocktailProcedure!)

                if (cocktailHistory?.text ?? "") != "" {
                    HistoryView(cocktail: cocktail, history: cocktailHistory!)
                }
                
                Spacer(minLength: 50)
            }
        }
    }
}

extension CocktailDetailView {
    var ingredientsView: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(cocktail.ingredients) { ingredient in
                HStack {
                    Text(selectedUnit == "oz." ? "\(ingredient.quantity, specifier: "%2g")" : "\(ingredient.mlQuantity, specifier: "%2g")")

                    Text(selectedUnit == "oz." ? ingredient.unit : ingredient.mlUnit)

                    Text(ingredient.name.capitalized)
                    
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.bottom)
    }
    
    var likeButton: some View {
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
            Label("Like", systemImage: favorites.contains(cocktail) ? "heart.fill" : "heart")
                .foregroundStyle(.red)
                .animation(.default, value: favorites.animated)
                .symbolEffect(.bounce.up, value: favorites.animated)
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
#Preview {
    TabView {
        NavigationStack {
            CocktailDetailView(cocktail: .example)
                .environmentObject(Favorites())
        }
    }
}
#endif
