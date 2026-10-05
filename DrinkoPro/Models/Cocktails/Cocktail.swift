//
//  Cocktail.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 23/04/2023.
//

import SwiftData
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

    /// The cocktail's sticker: the drink cut out with a white border on a transparent
    /// background. `nil` for the user's own cocktails.
    var stickerURL: URL? {
        guard !id.hasPrefix("user-") else { return nil }
        let name = Self.stickerNames[id] ?? id
        return URL(string: "https://raw.githubusercontent.com/cilippofilia/Drinko-stickers/main/drinko-\(name).png")
    }

    var image: String {
        glass
    }

    /// Drinks whose sticker is filed under another name.
    private static let stickerNames = [
        "augie-march": "manhattan",
        "gin-martini": "dry-martini"
    ]
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

    @MainActor
    func convertedQuantity(to targetUnit: String) -> Double {
        UnitConverter.convert(quantity, from: unit, to: targetUnit)
    }

    @MainActor
    func convertedUnit(to targetUnit: String) -> String {
        UnitConverter.unitLabel(for: unit, convertingTo: targetUnit)
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
        var id: String { "\(step)-\(text)" }
        let step: String
        let text: String
    }
}

@MainActor
@Observable
class CocktailsViewModel {
    var listOfCocktails: [Cocktail] = Bundle.main.decode([Cocktail].self, from: "cocktails.json")
    var listOfShots: [Cocktail] = Bundle.main.decode([Cocktail].self, from: "shots.json")
    private(set) var userCreatedCocktails: [UserCreatedCocktail] = []
    private(set) var userCocktails: [Cocktail] = []
    var histories: [History] = Bundle.main.decode([History].self, from: "history.json")
    var procedures: [Procedure] = Bundle.main.decode([Procedure].self, from: "procedure.json")
    var userProcedures: [Procedure] = []
    private var modelContext: ModelContext?

    var listOfAllDrinks: [Cocktail] {
        listOfCocktails + listOfShots + userCocktails
    }
    var sortOption: SortOption = .fromAtoZ
    var searchText = ""

    var sortedCocktails: [Cocktail] {
        sortedCocktails(in: listOfAllDrinks)
    }

    func cocktail(withID id: String, fallback: Cocktail) -> Cocktail {
        listOfAllDrinks.first { $0.id == id } ?? fallback
    }

    func isUserCreated(_ cocktail: Cocktail) -> Bool {
        userCocktails.contains { $0.id == cocktail.id }
    }

    func methodOptions(fallback: [String] = ["shake & fine strain"]) -> [String] {
        uniqueSorted(from: listOfAllDrinks.map(\.method), fallback: fallback)
    }

    func glassOptions(fallback: [String] = ["rock"]) -> [String] {
        uniqueSorted(from: listOfAllDrinks.map(\.glass), fallback: fallback)
    }

    func iceOptions(fallback: [String] = ["cubed"]) -> [String] {
        uniqueSorted(from: listOfAllDrinks.map(\.ice), fallback: fallback)
    }

    func unitOptions(fallback: [String] = ["oz.", "ml"]) -> [String] {
        uniqueSorted(
            from: listOfAllDrinks
                .flatMap(\.ingredients)
                .map(\.unit),
            fallback: fallback
        )
    }

    func procedureSteps(for cocktail: Cocktail) -> [String] {
        getCocktailProcedure(for: cocktail)?
            .procedure
            .map(\.text) ?? []
    }

    @MainActor
    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadUserCreatedCocktails()
    }

    func loadUserCreatedCocktails() {
        guard let modelContext else { return }
        let descriptor = FetchDescriptor<UserCreatedCocktail>(
            sortBy: [SortDescriptor(\.creationDate, order: .reverse)]
        )
        do {
            userCreatedCocktails = try modelContext.fetch(descriptor)
            refreshUserMappings()
        } catch {
            print("Warning: Unable to fetch user cocktails: \(error)")
        }
    }

    func getCocktailHistory(for cocktail: Cocktail) -> History? {
        return histories.first(where: { $0.id == cocktail.id })
    }

    func getCocktailProcedure(for cocktail: Cocktail) -> Procedure? {
        userProcedures.first(where: { $0.id == cocktail.id })
            ?? procedures.first(where: { $0.id == cocktail.id })
    }

    func getLinkedCocktails(for cocktail: Cocktail) -> [Cocktail] {
        guard let firstIngredient = cocktail.ingredients.first else { return [] }
        return getsSuggestedCocktails(with: firstIngredient.name, from: cocktail)
    }

    var filteredCocktails: [Cocktail] {
        filteredCocktails(filterOption: .all) { _ in false }
    }

    var cocktailsGrouped: [String: [Cocktail]] {
        groupedCocktails(filterOption: .all) { _ in false }
    }
    
    var sortedSectionKeys: [String] {
        sortedSectionKeys(filterOption: .all) { _ in false }
    }

    /// The filters that can return results for the given source. For example,
    /// user-created cocktails are never shots, so "Shots Only" is hidden when
    /// the list only shows the user's cocktails.
    func availableFilterOptions(for source: CocktailListSource) -> [FilterOption] {
        switch source {
        case .userAndApp:
            [.all, .cocktailsOnly, .shotsOnly, .favoritesOnly, .userCreatedOnly]
        case .appOnly:
            [.all, .cocktailsOnly, .shotsOnly, .favoritesOnly]
        case .userOnly:
            [.all, .favoritesOnly]
        }
    }

    func filteredCocktails(
        filterOption: FilterOption,
        source: CocktailListSource = .userAndApp,
        isFavorite: (Cocktail) -> Bool
    ) -> [Cocktail] {
        // Narrow to the chosen source first, then apply the filter within it.
        let appCocktails = source.includesAppCocktails ? listOfCocktails : []
        let appShots = source.includesAppCocktails ? listOfShots : []
        let ownCocktails = source.includesUserCocktails ? userCocktails : []

        let baseCocktails: [Cocktail]
        switch filterOption {
        case .all:
            baseCocktails = sortedCocktails(in: appCocktails + appShots + ownCocktails)
        case .cocktailsOnly:
            baseCocktails = sortedCocktails(in: appCocktails + ownCocktails)
        case .shotsOnly:
            baseCocktails = sortedCocktails(in: appShots)
        case .favoritesOnly:
            baseCocktails = sortedCocktails(in: appCocktails + appShots + ownCocktails).filter(isFavorite)
        case .userCreatedOnly:
            baseCocktails = sortedCocktails(in: ownCocktails)
        }

        guard !searchText.isEmpty else { return baseCocktails }
        return baseCocktails.filter { $0.name.localizedStandardContains(searchText) }
    }

    func groupedCocktails(
        filterOption: FilterOption,
        source: CocktailListSource = .userAndApp,
        isFavorite: (Cocktail) -> Bool
    ) -> [String: [Cocktail]] {
        let cocktails = filteredCocktails(filterOption: filterOption, source: source, isFavorite: isFavorite)
        let grouped = Dictionary(grouping: cocktails) { cocktail in
            switch sortOption {
            case .byGlass:
                return cocktail.glass.capitalizingFirstLetter()
            case .byIce:
                return cocktail.ice.capitalizingFirstLetter()
            case .fromAtoZ, .fromZtoA:
                let firstCharacter = cocktail.name.prefix(1).uppercased()
                if let char = firstCharacter.first, char.isLetter {
                    return String(char)
                }
                return Self.nonLetterSectionKey
            }
        }

        return grouped.mapValues { cocktails in
            cocktails.sorted { $0.name < $1.name }
        }
    }

    func sortedSectionKeys(
        filterOption: FilterOption,
        source: CocktailListSource = .userAndApp,
        isFavorite: (Cocktail) -> Bool
    ) -> [String] {
        let keys = Array(groupedCocktails(filterOption: filterOption, source: source, isFavorite: isFavorite).keys)
        let sortedKeys: [String]
        switch sortOption {
        case .fromZtoA:
            sortedKeys = keys.sorted(by: >)
        default:
            sortedKeys = keys.sorted(by: <)
        }

        // Names starting with a number or symbol share the "#" section, which goes at the bottom.
        guard sortOption == .fromAtoZ || sortOption == .fromZtoA, sortedKeys.contains(Self.nonLetterSectionKey) else {
            return sortedKeys
        }
        return sortedKeys.filter { $0 != Self.nonLetterSectionKey } + [Self.nonLetterSectionKey]
    }

    /// Section for cocktails whose name doesn't start with a letter.
    private static let nonLetterSectionKey = "#"

    private func sortedCocktails(in cocktails: [Cocktail]) -> [Cocktail] {
        cocktails.sorted(by: currentSortComparator)
    }

    private var currentSortComparator: (Cocktail, Cocktail) -> Bool {
        switch sortOption {
        case .fromAtoZ:
            return { $0.name < $1.name }
        case .fromZtoA:
            return { $1.name < $0.name }
        case .byGlass:
            return { $0.glass < $1.glass }
        case .byIce:
            return { $0.ice < $1.ice }
        }
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

    func addUserCocktail(_ details: UserCocktailDetails) {
        guard let modelContext else { return }
        let trimmedName = details.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let newCocktail = UserCreatedCocktail(
            name: trimmedName,
            method: details.method,
            glass: details.glass,
            garnish: details.garnish,
            ice: details.ice,
            extra: details.extra,
            ingredients: details.ingredients.map {
                UserIngredient(name: $0.name, quantity: $0.quantity, unit: $0.unit)
            },
            procedure: makeUserProcedure(from: details.procedureSteps),
            creationDate: Date(),
            lastUpdated: nil
        )
        newCocktail.ingredients?.forEach { $0.cocktail = newCocktail }
        if let procedure = newCocktail.procedure {
            procedure.cocktail = newCocktail
        }
        modelContext.insert(newCocktail)
        saveUserCocktails()
    }

    func updateUserCocktail(_ cocktail: Cocktail, with details: UserCocktailDetails) {
        guard let existing = userCreatedCocktails.first(where: { $0.id == cocktail.id }) else {
            return
        }

        existing.name = details.name.trimmingCharacters(in: .whitespacesAndNewlines)
        existing.method = details.method
        existing.glass = details.glass
        existing.garnish = details.garnish
        existing.ice = details.ice
        existing.extra = details.extra
        existing.lastUpdated = Date()
        existing.ingredients = details.ingredients.map {
            UserIngredient(name: $0.name, quantity: $0.quantity, unit: $0.unit)
        }
        existing.ingredients?.forEach { $0.cocktail = existing }
        existing.procedure = makeUserProcedure(from: details.procedureSteps)
        existing.procedure?.cocktail = existing
        saveUserCocktails()
    }

    func deleteUserCocktail(_ cocktail: Cocktail) {
        guard let modelContext else { return }
        guard let existing = userCreatedCocktails.first(where: { $0.id == cocktail.id }) else {
            return
        }
        modelContext.delete(existing)
        saveUserCocktails()
    }

    private func saveUserCocktails() {
        guard let modelContext else { return }
        do {
            try modelContext.save()
            loadUserCreatedCocktails()
        } catch {
            print("Warning: Unable to save user cocktails: \(error)")
        }
    }

    private func refreshUserMappings() {
        userCocktails = userCreatedCocktails.map { $0.cocktail }
        userProcedures = userCreatedCocktails.compactMap { userCocktail in
            guard let procedure = userCocktail.procedure else { return nil }
            let sortedSteps = (procedure.steps ?? []).sorted { $0.order < $1.order }
            let mappedSteps = sortedSteps.map { step in
                Procedure.Steps(step: "Step \(step.order)", text: step.text)
            }
            guard !mappedSteps.isEmpty else { return nil }
            return Procedure(id: userCocktail.id, procedure: mappedSteps)
        }
    }

    private func makeUserProcedure(from steps: [String]) -> UserProcedure? {
        let trimmed = steps
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard !trimmed.isEmpty else { return nil }
        let mappedSteps = trimmed.enumerated().map { index, text in
            UserProcedureStep(text: text, order: index + 1)
        }
        let procedure = UserProcedure(steps: mappedSteps)
        procedure.steps?.forEach { $0.procedure = procedure }
        return procedure
    }

    private func uniqueSorted(from values: [String], fallback: [String]) -> [String] {
        let cleaned = values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let set = Set(cleaned + fallback)
        return set.sorted()
    }
}

extension CocktailsViewModel {
    enum FilterOption {
        case all
        case cocktailsOnly
        case shotsOnly
        case favoritesOnly
        case userCreatedOnly
    }
}

public struct IngredientDraft {
    var name = ""
    var quantity = ""
    var unit: String
}
