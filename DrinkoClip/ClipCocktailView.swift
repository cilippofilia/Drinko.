//
//  ClipCocktailView.swift
//  DrinkoClip
//

import SwiftUI

/// The shared cocktail's full recipe, read-only.
struct ClipCocktailView: View {
    @Environment(\.locale) private var locale
    @AppStorage(CocktailUnitPreference.storageKey) private var unitPreference: CocktailUnitPreference = .automatic
    @State private var collapsed: Set<String> = []

    let cocktail: Cocktail
    let history: History?
    let procedure: Procedure?
    /// Called when the reader scrolls to the end of the recipe.
    let onReachEnd: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: detailCardInset) {
                ClipCocktailHeader(cocktail: cocktail)

                Picker("Units", selection: $unitPreference) {
                    ForEach(CocktailUnitPreference.allCases) { preference in
                        Text(preference.title).tag(preference)
                    }
                }
                .pickerStyle(.segmented)

                DetailSectionCard(
                    title: "Ingredients",
                    isCollapsed: collapsed.contains("ingredients"),
                    toggle: { toggle("ingredients") },
                    content: {
                        CocktailDetailsSection(
                            cocktail: cocktail,
                            selectedUnit: unitPreference.unit(for: locale),
                            showsOriginalUnits: false
                        )
                    }
                )

                if let procedure {
                    DetailSectionCard(
                        title: "Procedure",
                        isCollapsed: collapsed.contains("procedure"),
                        toggle: { toggle("procedure") },
                        content: {
                            ProcedureView(cocktail: cocktail, procedure: procedure)
                        }
                    )
                }

                if let history {
                    DetailSectionCard(
                        title: "History",
                        isCollapsed: collapsed.contains("history"),
                        toggle: { toggle("history") },
                        content: {
                            Text(history.text)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    )
                }

                Color.clear
                    .frame(height: 1)
                    .onAppear(perform: onReachEnd)
            }
            .padding(.horizontal)
            .frame(maxWidth: 700)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle(cocktail.name)
        .navigationBarTitleDisplayMode(.inline)
        .scrollIndicators(.hidden, axes: .vertical)
    }

    private func toggle(_ section: String) {
        withAnimation {
            if collapsed.contains(section) {
                collapsed.remove(section)
            } else {
                collapsed.insert(section)
            }
        }
    }
}
