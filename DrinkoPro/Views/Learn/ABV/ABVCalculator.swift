//
//  ABVCalculator.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 29/11/2023.
//

import SwiftUI

struct ABVCalculator: View {
    @FocusState private var isFocused: Bool
    @State private var viewModel = ABVCalculatorViewModel()

    var body: some View {
        ScrollView {
            ForEach($viewModel.bottles) { $bottle in
                ABVIngredientRow(
                    bottle: $bottle,
                    isFocused: $isFocused,
                    ingredientNumber: viewModel.ingredientNumber(for: bottle.id),
                    canRemove: viewModel.canRemoveIngredients,
                    onDelete: { viewModel.removeIngredient(id: bottle.id) }
                )
            }

            Button("Add ingredient", systemImage: "plus", action: viewModel.addIngredient)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .accessibilityHint("Adds another ingredient row.")

            ABVMethodPickers(method: $viewModel.method, serving: $viewModel.serving)
                .padding(.horizontal)

            VStack {
                Text("ABV")
                    .font(.headline)

                Text(viewModel.result / 100, format: .percent.precision(.fractionLength(2)))
                    .font(.title)
                    .bold()
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Calculated ABV")
            .accessibilityValue(Text(viewModel.result / 100, format: .percent.precision(.fractionLength(2))))
            .padding()

            Text("Use 'Built in the glass' and 'served up' to calculate the ABV of your own batches. Those two combined will not add any dilution to the drink.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.vertical)
        }
        .navigationTitle("ABV Calculator")
        .padding(.horizontal)
        .scrollIndicators(.hidden, axes: .vertical)
        .scrollBounceBehavior(.basedOnSize)
        #if os(iOS)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()

                Button("Done") {
                    isFocused = false
                }
            }
        }
        #endif
    }
}

#if DEBUG
#Preview {
    ABVCalculator()
}
#endif
