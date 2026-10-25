import SwiftUI

/// The compact card Siri and Shortcuts show with a spoken recipe: name, serving and ingredients.
struct RecipeSnippetView: View {
    let name: String
    let serving: String
    let ingredients: [Line]

    struct Line: Identifiable {
        let id: Int
        let amount: String
        let name: String
    }

    @MainActor
    init(cocktail: Cocktail, unit: String) {
        name = CocktailNameMatcher.spokenName(cocktail.name)
        serving = [cocktail.glass, cocktail.ice]
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty && $0 != "-" }
            .joined(separator: " · ")
        ingredients = cocktail.ingredients.enumerated().map { index, ingredient in
            let quantity = ingredient.convertedQuantity(to: unit)
            let unitLabel = ingredient.convertedUnit(to: unit)
            let rounded = (quantity * 100).rounded() / 100
            let amount = rounded > 0
                ? "\(rounded.formatted(.number.precision(.fractionLength(0...2)))) \(unitLabel == "-" ? "" : unitLabel)"
                    .trimmingCharacters(in: .whitespaces)
                : ""
            return Line(id: index, amount: amount, name: ingredient.name)
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(name)
                .font(.title2.bold())
                .foregroundStyle(Color("Dr. Blue"))
            if !serving.isEmpty {
                Text(serving)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Divider()
            ForEach(ingredients) { line in
                HStack {
                    Text(line.name)
                    Spacer()
                    Text(line.amount)
                        .foregroundStyle(.secondary)
                }
                .font(.callout)
            }
        }
        .padding()
    }
}
