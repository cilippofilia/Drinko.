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

    @State private var showHistory = false
    @State private var showProcedure = false

    @State private var selectedUnit = "ml"
    @State private var showDeleteConfirmation = false
    @State private var showEditSheet = false

    let cocktail: Cocktail
    @State private var cocktailID: String

    var toolbarPlacement: ToolbarItemPlacement {
        #if os(iOS)
        .topBarTrailing
        #elseif os(macOS)
        .automatic
        #endif
    }

    init(cocktail: Cocktail) {
        self.cocktail = cocktail
        _cocktailID = State(initialValue: cocktail.id)
    }

    private var activeCocktail: Cocktail {
        viewModel.cocktail(withID: cocktailID, fallback: cocktail)
    }

    var body: some View {
        ScrollView {
            cocktailContent
        }
        .navigationTitle(activeCocktail.name)
        .scrollIndicators(.hidden, axes: .vertical)
        .scrollBounceBehavior(.basedOnSize)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: toolbarPlacement) {
                HistoryButtonView(
                    history: viewModel.getCocktailHistory(for: activeCocktail),
                    showHistory: $showHistory,
                    cocktail: activeCocktail
                )
            }
            ToolbarItem(placement: toolbarPlacement) {
                LikeButtonView(cocktail: activeCocktail)
            }
            if viewModel.isUserCreated(activeCocktail) {
                ToolbarItem(placement: toolbarPlacement) {
                    Button(action: {
                        showEditSheet = true
                    }) {
                        Image(systemName: "pencil.line")
                    }
                    .accessibilityLabel("Edit Cocktail")
                    .accessibilityHint("Edits this cocktail")
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            NavigationStack {
                UserCocktailForm(
                    methodOptions: viewModel.methodOptions(),
                    glassOptions: viewModel.glassOptions(),
                    iceOptions: viewModel.iceOptions(),
                    unitOptions: viewModel.unitOptions(),
                    editingCocktail: activeCocktail,
                    editingProcedureSteps: viewModel.procedureSteps(for: activeCocktail)
                )
            }
        }
    }
    
    var cocktailContent: some View {
        VStack {
            CocktailImageHeader(cocktail: activeCocktail)
            
            VStack(alignment: .leading) {
                if !viewModel.isUserCreated(activeCocktail) {
                    CocktailUnitPicker(selectedUnit: $selectedUnit)
                }
                
                Text(activeCocktail.name)
                    .font(.title.bold())
                
                Divider()
                
                CocktailDetailsSection(
                    cocktail: activeCocktail,
                    selectedUnit: selectedUnit
                )
                
                Divider()

                if let procedure = viewModel.getCocktailProcedure(for: activeCocktail) {
                    ProcedureView(
                        cocktail: cocktail,
                        procedure: procedure
                    )
                    .padding(.top, 8)
                }

                if !viewModel.getLinkedCocktails(for: activeCocktail).isEmpty {
                    Text("You may also like")
                        .font(sizeClass == .compact ? .title3.bold() : .title.bold())
                        .padding(.top, 8)

                    LinkedCocktailsView(
                        cocktails: viewModel.getLinkedCocktails(for: activeCocktail)
                    )
                    .padding(.bottom, 8)

                    Divider()
                }

                if viewModel.isUserCreated(activeCocktail) {
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
                    viewModel.deleteUserCocktail(activeCocktail)
                    dismiss()
                }
            )
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently remove your cocktail.")
        }
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
