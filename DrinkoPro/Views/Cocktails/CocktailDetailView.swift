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
    
    var favorites = Favorites()
    var units = ["ml", "oz."]

    @State private var viewModel = CocktailsViewModel()

    @State private var showHistory = false
    @State private var showProcedure = false

    @State private var selectedUnit = "ml"

    @State private var frameSize: CGFloat = 280
    @State private var corners: CGFloat = 10

    let cocktail: Cocktail
    var cocktailHistory: History? {
        return viewModel.histories.first(where: { $0.id == cocktail.id })
    }
    var cocktailProcedure: Procedure? {
        return viewModel.procedures.first(where: { $0.id == cocktail.id })
    }
    var linkedCocktails: [Cocktail] {
        viewModel.getsSuggestedCocktails(with: "\(cocktail.ingredients[0].name)", from: cocktail)
    }

    var body: some View {
        ScrollView {
            if sizeClass == .compact {
                compactDetailView
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            historyButton
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            likeButton
                        }
                    }
            } else {
                regularDetailView
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            historyButton
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            likeButton
                        }
                    }
            }
        }
        .navigationTitle(cocktail.name)
        .navigationBarTitleDisplayMode(.inline)
        .scrollIndicators(.hidden, axes: .vertical)
        .scrollBounceBehavior(.basedOnSize)
    }

    var compactDetailView: some View {
        VStack {
            AsyncImage(url: URL(string: cocktail.image)) { state in
                switch state {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    imageFailedToLoad
                @unknown default:
                    EmptyView()
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

                VStack(alignment: .leading, spacing: 0) {
                    ProcedureView(
                        cocktail: cocktail,
                        procedure: cocktailProcedure!
                    )

                    if !linkedCocktails.isEmpty {
                        Text("You may also like")
                            .font(sizeClass == .compact ? .title3.bold() : .title.bold())
                            .padding(.vertical)

                        linkedCocktailRow
                    }
                }
                .padding(.vertical)
            }
            Spacer(minLength: 50)
        }
        .frame(width: compactScreenWidth)
    }

    var regularDetailView: some View {
        VStack {
            AsyncImage(url: URL(string: cocktail.image)) { state in
                switch state {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    imageFailedToLoad
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: regularScreenWidth,
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
                .frame(maxWidth: regularScreenWidth / 2)
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

                VStack(alignment: .leading, spacing: 0) {
                    ProcedureView(
                        cocktail: cocktail,
                        procedure: cocktailProcedure!
                    )

                    if !linkedCocktails.isEmpty {
                        Text("You may also like")
                            .font(sizeClass == .compact ? .title3.bold() : .title.bold())
                            .padding(.vertical)

                        linkedCocktailRow
                    }
                }
                .padding(.vertical)
            }
        }
        .frame(width: regularScreenWidth)
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
                .animation(.default, value: favorites.hasEffect)
                .symbolEffect(.bounce.up, value: favorites.hasEffect)
        }
        .buttonStyle(.plain)
    }

    var historyButton: some View {
        Group {
            if (cocktailHistory?.text ?? "") != "" {
                Button(action: {
                    showHistory.toggle()
                }) {
                    Label("History", systemImage: "book")
                }
                .sheet(isPresented: $showHistory) {
                    HistoryView(cocktail: cocktail, history: cocktailHistory!)
                        .presentationDetents([.medium, .large])
                }
            }
        }
    }

    var linkedCocktailRow: some View {
        Group {
            ForEach(linkedCocktails) { link in
                NavigationLink(value: link) {
                    HStack {
                        CocktailRowView(favorites: favorites, cocktail: link)
                        HStack {
                            if favorites.contains(cocktail) {
                                Image(systemName: "heart.fill")
                                    .imageScale(.small)
                                    .foregroundStyle(.red)
                            }

                            Image(systemName: "chevron.right")
                                .bold()
                                .imageScale(.small)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#if DEBUG
#Preview {
    TabView {
        NavigationStack {
            CocktailDetailView(cocktail: .example)
                .environment(Favorites())
        }
    }
}
#endif
