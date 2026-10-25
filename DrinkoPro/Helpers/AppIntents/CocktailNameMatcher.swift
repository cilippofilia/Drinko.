import Foundation

/// Resolves spoken or typed cocktail names against the library.
nonisolated enum CocktailNameMatcher {
    /// The name as it should be spoken: a trailing parenthetical such as a year is dropped.
    static func spokenName(_ name: String) -> String {
        name.replacing(/\s*\([^)]*\)\s*$/, with: "")
    }

    /// Case- and diacritic-folded form without article, "cocktail" suffix, parentheticals or punctuation.
    static func normalized(_ text: String) -> String {
        var result = text
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
            .lowercased()
            .replacing(/\([^)]*\)/, with: " ")
        result = String(result.map { $0.isLetter || $0.isNumber ? $0 : " " })
        var words = result.split(separator: " ").map(String.init)
        if words.count > 1, words.first == "the" { words.removeFirst() }
        if words.count > 1, words.last == "cocktail" { words.removeLast() }
        return words.joined(separator: " ")
    }

    /// The name with punctuation replaced by spaces and the words kept, e.g. "Corpse Reviver 2".
    static func punctuationStripped(_ name: String) -> String {
        String(name.map { $0.isLetter || $0.isNumber ? $0 : " " })
            .split(separator: " ")
            .joined(separator: " ")
    }

    /// Exact normalized matches first; otherwise cocktails whose name contains the query.
    /// Spaces are ignored on both sides, so "oldfashioned" finds "Old Fashioned".
    static func matches(_ query: String, in cocktails: [Cocktail]) -> [Cocktail] {
        let target = compact(normalized(query))
        guard !target.isEmpty else { return [] }
        let exact = cocktails.filter { compact(normalized($0.name)) == target }
        if !exact.isEmpty { return exact }
        return cocktails.filter { compact(normalized($0.name)).contains(target) }
    }

    /// The cocktail with the smallest edit distance, if close enough to be a plausible typo.
    static func closestMatch(to query: String, in cocktails: [Cocktail]) -> Cocktail? {
        let target = Array(normalized(query))
        guard !target.isEmpty else { return nil }
        let limit = max(2, target.count / 4)
        var best: (cocktail: Cocktail, distance: Int)?
        for cocktail in cocktails {
            let distance = editDistance(target, Array(normalized(cocktail.name)))
            if best == nil || distance < best?.distance ?? .max {
                best = (cocktail, distance)
            }
        }
        guard let best, best.distance <= limit else { return nil }
        return best.cocktail
    }

    private static func compact(_ text: String) -> String {
        text.replacing(" ", with: "")
    }

    /// Plain Levenshtein distance.
    private static func editDistance(_ lhs: [Character], _ rhs: [Character]) -> Int {
        if lhs.isEmpty { return rhs.count }
        if rhs.isEmpty { return lhs.count }
        var previous = Array(0...rhs.count)
        for (row, left) in lhs.enumerated() {
            var current = [row + 1]
            for (col, right) in rhs.enumerated() {
                let cost = left == right ? 0 : 1
                current.append(min(previous[col + 1] + 1, current[col] + 1, previous[col] + cost))
            }
            previous = current
        }
        return previous[rhs.count]
    }
}
