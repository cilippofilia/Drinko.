import Foundation

/// Picks the Cabinet category a bottle belongs in without asking, when exactly one fits.
enum CabinetCategoryGuesser {
    static func guess(bottle: String, among categories: [CategoryCandidate]) -> CategoryCandidate? {
        guard let bottleSpirit = MainSpirit(ingredientName: bottle) else { return nil }
        let matches = categories.filter { category in
            category.color == bottleSpirit.colorName || spirit(forCategoryNamed: category.name) == bottleSpirit
        }
        return matches.count == 1 ? matches.first : nil
    }

    /// Whether `bottle` is already among `existingNames`, ignoring case, accents and edge spaces.
    static func isDuplicate(_ bottle: String, in existingNames: [String]) -> Bool {
        let wanted = normalized(bottle)
        guard !wanted.isEmpty else { return false }
        return existingNames.contains { normalized($0) == wanted }
    }

    private static func normalized(_ name: String) -> String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
    }

    /// The spirit a category name gives. Each word is also tried without a trailing "s", so
    /// "Gins" counts as gin.
    private static func spirit(forCategoryNamed categoryName: String) -> MainSpirit? {
        if let spirit = MainSpirit(ingredientName: categoryName) { return spirit }
        for word in categoryName.split(whereSeparator: { !$0.isLetter }) where word.lowercased().hasSuffix("s") {
            if let spirit = MainSpirit(ingredientName: String(word.dropLast())) { return spirit }
        }
        return nil
    }
}
