import Foundation

/// Picks the Cabinet category a bottle belongs in without asking, when exactly one fits.
enum CabinetCategoryGuesser {
    static func guess(bottle: String, among categories: [CategoryCandidate]) -> CategoryGuess {
        // A word the bottle shares with a category's name decides first, so "Carpano Vermouth"
        // lands in "Vermouth" even though vermouth isn't a spirit keyword.
        let bottleWords = nameWords(bottle)
        let named = categories.filter { !nameWords($0.name).isDisjoint(with: bottleWords) }
        switch named.count {
        case 0: break
        case 1: return .match(named[0])
        default: return .ambiguous(named)
        }

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

    /// The words of `name` that can identify a category: case- and diacritic-folded, with a
    /// trailing "s" dropped so "Bitters" and "bitter" agree. Words under 3 letters and "&" are
    /// ignored.
    private static func nameWords(_ name: String) -> Set<String> {
        let folded = name.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil).lowercased()
        let words = folded.split(whereSeparator: { !$0.isLetter })
            .map(String.init)
            .filter { $0.count >= 3 && $0 != "&" }
            .map { $0.hasSuffix("s") ? String($0.dropLast()) : $0 }
        return Set(words)
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
