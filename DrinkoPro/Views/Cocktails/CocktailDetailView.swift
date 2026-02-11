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
    @Environment(CocktailsViewModel.self) private var viewModel
    @Environment(Favorites.self) private var favorites
    
    var units = ["ml", "oz."]

    @State private var showHistory = false
    @State private var showProcedure = false

    @State private var selectedUnit = "ml"
    @State private var showDeleteConfirmation = false

    let cocktail: Cocktail

    var toolbarPlacement: ToolbarItemPlacement {
        #if os(iOS)
        .topBarTrailing
        #elseif os(macOS)
        .automatic
        #endif
    }

    var body: some View {
        ScrollView {
            cocktailContent
        }
        .navigationTitle(cocktail.name)
        .scrollIndicators(.hidden, axes: .vertical)
        .scrollBounceBehavior(.basedOnSize)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: toolbarPlacement) {
                HistoryButtonView(
                    history: viewModel.getCocktailHistory(for: cocktail),
                    showHistory: $showHistory,
                    cocktail: cocktail
                )
            }
            ToolbarItem(placement: toolbarPlacement) {
                LikeButtonView(cocktail: cocktail)
            }
        }
    }
    
    var cocktailContent: some View {
        VStack {
            CocktailImageHeader(cocktail: cocktail)
            
            VStack(alignment: .leading) {
                CocktailUnitPicker(selectedUnit: $selectedUnit)
                
                Text(cocktail.name)
                    .font(.title.bold())
                
                Divider()
                
                CocktailDetailsSection(
                    cocktail: cocktail,
                    selectedUnit: selectedUnit
                )
                
                Divider()

                if let procedure = viewModel.getCocktailProcedure(for: cocktail) {
                    CocktailRelatedSection(cocktail: cocktail, procedure: procedure)

                    Divider()
                }

                if !viewModel.getLinkedCocktails(for: cocktail).isEmpty {
                    Text("You may also like")
                        .font(sizeClass == .compact ? .title3.bold() : .title.bold())
                        .padding(.vertical)

                    LinkedCocktailsView(
                        cocktails: viewModel.getLinkedCocktails(for: cocktail),
                        procedure: viewModel.getCocktailProcedure(for: cocktail)
                    )

                    Divider()
                }

                if isUserCreated {
                    DeleteButtonView(
                        label: "Delete",
                        action: {
                            showDeleteConfirmation = true
                        }
                    )
                    .buttonStyle(.bordered)
                    .padding(.top, 8)
                }
            }
            Spacer(minLength: 50)
        }
        #if os(iOS)
        .frame(width: screenWidth * (sizeClass == .compact ? 0.9 : 0.7))
        #elseif os(macOS)
        .padding(.horizontal)
        #endif
        .alert("Delete Cocktail?", isPresented: $showDeleteConfirmation) {
            DeleteButtonView(
                label: "Delete",
                action: {
                    viewModel.deleteUserCocktail(cocktail)
                    dismiss()
                }
            )
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently remove your cocktail.")
        }
    }
    
    private var isUserCreated: Bool {
        viewModel.userCocktails.contains { $0.id == cocktail.id }
    }

}

#if DEBUG
#Preview {
    TabView {
        NavigationStack {
            CocktailDetailView(cocktail: .userCreatedExample)
                .environment(CocktailsViewModel())
                .environment(Favorites())
        }
    }
}
#endif
