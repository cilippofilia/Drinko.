//
//  Cocktail.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 23/04/2023.
//

import SwiftUI

struct Cocktail: Codable, Equatable, Identifiable, Hashable {
    let id: String
    let name: String
    let method: String
    let glass: String
    let garnish: String
    let ice: String
    let extra: String
    
    let ingredients: [Ingredient]

    var pic: String {
        if id == "augie-march" {
            "https://raw.githubusercontent.com/cilippofilia/drinko-cocktail-pics/main/manhattan-img.jpg"
        } else {
            "https://raw.githubusercontent.com/cilippofilia/drinko-cocktail-pics/main/\(id)-img.jpg"
        }
    }

    var image: String {
        glass
    }
}

enum SortOption {
    case fromAtoZ
    case fromZtoA
    case byGlass
    case byIce
}

struct Ingredient: Codable, Equatable, Identifiable, Hashable {
    var id: String { name }
    let name: String
    let quantity: Double
    let unit: String

    @MainActor
    var mlQuantity: Double {
        if unit == "oz." {
            return UnitConverter.convert(quantity, from: "oz.", to: "ml")
        }
        return quantity
    }

    @MainActor
    var mlUnit: String {
        UnitConverter.unitLabel(for: unit, convertingTo: "ml")
    }
}

struct History: Codable, Equatable, Identifiable {
    let id: String
    let text: String    
}

struct Procedure: Codable, Equatable, Identifiable {
    let id: String
    let procedure: [Steps]
    
    struct Steps: Codable, Equatable, Identifiable {
        var id: String { text }
        let step: String
        let text: String
    }
}

@MainActor
@Observable
class CocktailsViewModel {
    var listOfCocktails: [Cocktail] = Bundle.main.decode([Cocktail].self, from: "cocktails.json")
    var listOfShots: [Cocktail] = Bundle.main.decode([Cocktail].self, from: "shots.json")
    var histories: [History] = Bundle.main.decode([History].self, from: "history.json")
    var procedures: [Procedure] = Bundle.main.decode([Procedure].self, from: "procedure.json")

    var listOfAllDrinks: [Cocktail] {
        listOfCocktails + listOfShots
    }
    var sortOption: SortOption = .fromAtoZ
    var searchText = ""

    var sortedCocktails: [Cocktail] {
        switch sortOption {
        case .fromAtoZ:
            return listOfAllDrinks.sorted { $0.name < $1.name }
        case .fromZtoA:
            return listOfAllDrinks.sorted { $1.name < $0.name }
        case .byGlass:
            return listOfAllDrinks.sorted { $0.glass < $1.glass }
        case .byIce:
            return listOfAllDrinks.sorted { $0.ice < $1.ice }
        }
    }

    func getCocktailHistory(for cocktail: Cocktail) -> History? {
        return histories.first(where: { $0.id == cocktail.id })
    }

    func getCocktailProcedure(for cocktail: Cocktail) -> Procedure? {
        return procedures.first(where: { $0.id == cocktail.id })
    }

    func getLinkedCocktails(for cocktail: Cocktail) -> [Cocktail] {
        getsSuggestedCocktails(with: "\(cocktail.ingredients[0].name)", from: cocktail)
    }

    var filteredCocktails: [Cocktail] {
        guard !searchText.isEmpty else { return sortedCocktails }
        return sortedCocktails.filter { $0.name.localizedStandardContains(searchText) }
    }

    func getsSuggestedCocktails(with ingredient: String, from cocktail: Cocktail) -> [Cocktail] {
        var list: [Cocktail] = []
        var seen: Set<String> = []

        for drink in sortedCocktails {
            if drink.id == cocktail.id { continue }
            for ingr in drink.ingredients {
                if ingr.name.contains(ingredient) {
                    if !seen.contains(drink.id) {
                        list.append(drink)
                        seen.insert(drink.id)
                    }
                }
            }
        }
        list.shuffle()
        return Array(list.prefix(5))
    }
}
