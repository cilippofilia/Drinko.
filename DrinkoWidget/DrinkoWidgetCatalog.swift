//
//  DrinkoWidgetCatalog.swift
//  DrinkoWidget
//
//  Created by Filippo Cilia on 04/04/2026.
//

import Foundation

// The widget only needs a lightweight read-only model, so it decodes a small
// subset of the cocktail JSON instead of pulling in the full app view model.
struct DrinkoWidgetCocktail: Decodable, Hashable {
    let id: String
    let name: String
    let method: String
    let glass: String
    let ingredients: [DrinkoWidgetIngredient]

    var pic: String {
        if id == "augie-march" {
            "https://raw.githubusercontent.com/cilippofilia/drinko-clear-cocktail-pics/main/manhattan-img.png"
        } else {
            "https://raw.githubusercontent.com/cilippofilia/drinko-clear-cocktail-pics/main/\(id)-img.png"
        }
    }

    var imageURL: URL? {
        URL(string: pic)
    }
}

struct DrinkoWidgetIngredient: Decodable, Hashable {
    let name: String
    let quantity: String
    let unit: String
}

enum DrinkoWidgetCatalog {
    static func loadCocktails(from bundle: Bundle = .main) -> [DrinkoWidgetCocktail] {
        guard
            let url = bundle.url(forResource: "cocktails", withExtension: "json"),
            let data = try? Data(contentsOf: url)
        else {
            return [sampleCocktail]
        }

        do {
            return try JSONDecoder().decode([DrinkoWidgetCocktail].self, from: data)
        } catch {
            return [sampleCocktail]
        }
    }

    static func cocktailOfTheDay(
        from cocktails: [DrinkoWidgetCocktail],
        on date: Date = .now,
        calendar: Calendar = .current
    ) -> DrinkoWidgetCocktail {
        guard !cocktails.isEmpty else {
            return sampleCocktail
        }

        let startOfDay = calendar.startOfDay(for: date)
        let dayIndex = Int(startOfDay.timeIntervalSinceReferenceDate / 86_400)
        let normalizedIndex = abs(dayIndex) % cocktails.count
        return cocktails[normalizedIndex]
    }

    static func nextRefreshDate(
        after date: Date = .now,
        calendar: Calendar = .current
    ) -> Date {
        let startOfDay = calendar.startOfDay(for: date)
        return calendar.date(byAdding: .day, value: 1, to: startOfDay)
            ?? date.addingTimeInterval(86_400)
    }

    static let sampleCocktail = DrinkoWidgetCocktail(
        id: "mojito",
        name: "Mojito",
        method: "shake & strain",
        glass: "highball",
        ingredients: [
            DrinkoWidgetIngredient(name: "white rum", quantity: "45", unit: "ml"),
            DrinkoWidgetIngredient(name: "lime juice", quantity: "15", unit: "ml"),
            DrinkoWidgetIngredient(name: "simple syrup", quantity: "15", unit: "ml"),
            DrinkoWidgetIngredient(name: "mint", quantity: "1", unit: "handful")
        ]
    )
}
