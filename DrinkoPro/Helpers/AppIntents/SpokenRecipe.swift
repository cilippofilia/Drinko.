import Foundation

/// Turns a cocktail into the sentences Siri reads aloud.
///
/// Every phrase is a whole localized string, never glued from pieces, because the five
/// supported languages don't share word order ("1 and a half ounces" / "un'oncia e mezza").
/// Cocktail, ingredient, glass, ice and garnish names are spoken as stored, in English.
@MainActor
struct SpokenRecipe {
    let cocktail: Cocktail
    let steps: [String]
    /// The unit the user hears: `"oz."` or `"ml"`.
    let unit: String
    let locale: Locale

    init(cocktail: Cocktail, steps: [String], unit: String, locale: Locale) {
        self.cocktail = cocktail
        self.steps = steps
        self.unit = unit
        self.locale = locale
    }

    /// "Zombie. Tiki glass, crushed ice. 1 and a half ounces aged jamaican rum, …".
    var ingredientsSpeech: String {
        var speech = "\(CocktailNameMatcher.spokenName(cocktail.name)). "

        let serving = [spokenGlass, Self.meaningful(cocktail.ice)].compactMap(\.self)
        if !serving.isEmpty {
            speech += serving.joined(separator: ", ") + ". "
        }

        let lines = cocktail.ingredients.map(ingredientLine)
        speech += lines.joined(separator: ", ") + "."
        return speech
    }

    /// "Step 1: … Step 2: … Garnish: …".
    var methodSpeech: String {
        var parts = steps.enumerated().map { index, step in
            let label = text("Step \(index + 1):")
            return "\(label) \(Self.sentence(step))"
        }
        if let garnish = Self.meaningful(cocktail.garnish) {
            parts.append("\(text("Garnish:")) \(Self.sentence(garnish))")
        }
        return parts.joined(separator: " ")
    }

    /// The quantity as it is said, for example "1 and a half ounces" or "3 dashes".
    static func spokenAmount(_ quantity: Double, unit: String, locale: Locale) -> String {
        let quantity = (quantity * 100).rounded() / 100
        let whole = quantity.rounded(.towardZero)
        let fraction = quantity - whole
        let count = Int(whole)

        switch unit {
        case "oz.":
            if fraction == 0 { return text("\(count) ounces", locale) }
            if fraction == 0.5 {
                return count == 0 ? text("half an ounce", locale) : text("\(count) and a half ounces", locale)
            }
            if count == 0, fraction == 0.75 { return text("three quarters of an ounce", locale) }
            if count == 0, fraction == 0.25 { return text("a quarter of an ounce", locale) }
            return text("\(decimal(quantity, locale)) ounces", locale)
        case "ml":
            return text("\(Int(quantity.rounded())) millilitres", locale)
        case "dash", "dashes":
            return fraction == 0 ? text("\(count) dashes", locale) : text("\(decimal(quantity, locale)) dashes", locale)
        case "-", "":
            return fraction == 0 ? integer(count, locale) : decimal(quantity, locale)
        default:
            // Other units are spoken as stored.
            let number = fraction == 0 ? integer(count, locale) : decimal(quantity, locale)
            return "\(number) \(unit)"
        }
    }

    // MARK: - Ingredients

    private func ingredientLine(_ ingredient: Ingredient) -> String {
        guard ingredient.quantity > 0 else { return ingredient.name }
        let quantity = ingredient.convertedQuantity(to: unit)
        let amount = Self.spokenAmount(quantity, unit: ingredient.convertedUnit(to: unit), locale: locale)
        return text("\(amount) \(ingredient.name)")
    }

    private var spokenGlass: String? {
        guard let glass = Self.meaningful(cocktail.glass) else { return nil }
        let name = glass.prefix(1).uppercased() + glass.dropFirst()
        let isVessel = glass.hasSuffix("mug") || glass.hasSuffix("cup") || glass.hasSuffix("glass")
        return isVessel ? name : "\(name) glass"
    }

    // MARK: - Helpers

    private static func integer(_ value: Int, _ locale: Locale) -> String {
        value.formatted(.number.locale(locale))
    }

    private static func decimal(_ value: Double, _ locale: Locale) -> String {
        value.formatted(.number.precision(.fractionLength(0...2)).locale(locale))
    }

    /// Resolves `value` in the language of `locale`, not just formatted for it.
    private static func text(_ value: String.LocalizationValue, _ locale: Locale) -> String {
        String(localized: LocalizedStringResource(value, locale: locale, bundle: .main))
    }

    private func text(_ value: String.LocalizationValue) -> String {
        Self.text(value, locale)
    }

    /// `nil` for the "-" placeholder and for empty values.
    private static func meaningful(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty || trimmed == "-" ? nil : trimmed
    }

    /// Ends the text with a full stop unless it already has closing punctuation.
    private static func sentence(_ value: String) -> String {
        guard let last = value.last else { return value }
        return ".!?".contains(last) ? value : value + "."
    }
}
