import Foundation

/// Picks the Cabinet category a bottle belongs in without asking, when exactly one fits.
enum CabinetCategoryGuesser {
    static func guess(bottle: String, among categories: [CategoryCandidate]) -> CategoryGuess {
        guard let bottleSpirit = MainSpirit(ingredientName: bottle) else { return .unknown }
        // A category's name decides first; its color counts only when the name gives no spirit.
        let matches = categories.filter { category in
            if let nameSpirit = spirit(forCategoryNamed: category.name) {
                return nameSpirit == bottleSpirit
            }
            return category.color == bottleSpirit.colorName
        }
        switch matches.count {
        case 0: return .unknown
        case 1: return .match(matches[0])
        default: return .ambiguous(matches)
        }
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
