//
//  RecipeBottle.swift
//  DrinkoPro
//

import Foundation

/// What a recipe ingredient asks of the cabinet: nothing (a pantry staple), a base spirit,
/// a specific bottle style, or a bottle the app can't classify.
nonisolated enum RecipeBottle: Hashable, Sendable {
    case staple
    case spirit(MainSpirit)
    case style(BottleStyle)
    case other(String)

    /// Style first, then staple, then base spirit. A liqueur family without a style stays `other`.
    init(name: String) {
        if let style = BottleStyle(name: name) {
            self = .style(style)
        } else if Self.isStaple(name) {
            self = .staple
        } else if let spirit = MainSpirit(ingredientName: name), spirit.isBaseSpirit {
            self = .spirit(spirit)
        } else {
            self = .other(Self.fold(name).trimmingCharacters(in: .whitespaces))
        }
    }

    /// The interchangeable options in a name like "bourbon or rye whiskey", without parenthesised notes.
    static func alternatives(in name: String) -> [String] {
        var text = ""
        var depth = 0
        for character in name {
            if character == "(" {
                depth += 1
            } else if character == ")" {
                depth = max(0, depth - 1)
            } else if depth == 0 {
                text.append(character)
            }
        }
        for separator in [" or ", "/", " o ", " ou ", " oder "] {
            text = text.replacing(separator, with: "|")
        }
        return text.split(separator: "|")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            // "pinot noir or similar" names no second bottle.
            .filter { !$0.isEmpty && $0.lowercased() != "similar" }
    }

    /// Whether the ingredient comes from the kitchen rather than the bar, so it never counts against a cabinet.
    static func isStaple(_ name: String) -> Bool {
        // Juices and syrups are staples; any other spirit family (rum, liqueur) is a bottle.
        if let spirit = MainSpirit(ingredientName: name) {
            return !spirit.isBaseSpirit && spirit != .liqueur
        }
        // Whole words only, so "chocolate bitters" doesn't hit "cola".
        let words = " " + fold(name).split { !$0.isLetter }.joined(separator: " ") + " "
        guard !bottleWords.contains(where: { words.contains(" \($0) ") }) else { return false }
        return stapleFragments.contains { words.contains(" \($0) ") }
    }

    static func fold(_ name: String) -> String {
        name.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
    }

    /// Words that make a name a bottle even when it also names a kitchen item ("lemon bitters", "cream sherry").
    private static let bottleWords = [
        "bitters", "bitter", "wine", "sherry", "vermouth", "vino", "vin", "wein", "wermut", "amaro", "liqueur"
    ]

    /// Folded kitchen words and phrases (en, it, es, fr, de), matched as whole words.
    private static let stapleFragments = [
        // sugar, honey
        "sugar", "zucchero", "azucar", "sucre", "zucker", "honey", "miele", "miel", "honig",
        // fruit and produce
        "lemon", "lemons", "lime", "limes", "orange", "oranges", "grapefruit", "limone", "arancia", "limon",
        "naranja", "citron", "pamplemousse", "zitrone", "strawberry", "strawberries", "raspberry", "raspberries",
        "blackberry", "blackberries", "blueberries", "fragola", "fresa", "fraise", "erdbeere", "cucumber",
        "cetriolo", "pepino", "concombre", "gurke", "apple", "pear", "peach", "pineapple", "mango", "banana",
        "cherry", "cherries", "grapes", "watermelon", "marmalade", "marmelade", "jam", "marmellata", "mermelada",
        "confiture", "puree", "passionfruit", "tomato", "olive", "olives", "celery", "onion", "brine",
        // herbs and spices
        "mint", "menta", "menthe", "minze", "basil", "basilico", "albahaca", "basilic", "basilikum", "rosemary",
        "thyme", "sage", "cinnamon", "cannella", "canela", "cannelle", "zimt", "nutmeg", "vanilla", "cloves",
        "cardamom", "star anise", "herbs", "chili", "chilli", "jalapeno",
        // egg, dairy
        "egg", "eggs", "uovo", "albume", "huevo", "clara", "oeuf", "eiweiss", "heavy cream", "double cream",
        "whipping cream", "single cream", "light cream", "fresh cream", "cream of coconut", "coconut cream",
        "panna", "creme fraiche", "sahne", "milk", "latte", "leche", "lait", "milch",
        // coffee, tea, water
        "coffee", "espresso", "caffe", "cafe", "kaffee", "tea", "water", "acqua", "agua", "eau", "wasser",
        // seasoning, sauces
        "salt", "sale", "salz", "pepper", "pepe", "pimienta", "poivre", "pfeffer", "sauce", "salsa", "tabasco",
        "worcestershire", "worchestershire", "vinegar", "aceto", "vinagre", "vinaigre", "essig", "butter",
        // mixers
        "soda", "tonic", "ginger beer", "ginger ale", "cola", "lemonade", "limonata", "limonada", "limonade",
        "cranberry"
    ]
}
