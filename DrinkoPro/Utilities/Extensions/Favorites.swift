//
//  Favorites.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 28/04/2023.
//

import SwiftUI

enum SaveKey: String {
    case cocktails
    case items
}

class Favorites: ObservableObject {
    // What the user has favourited
    private var cocktails: Set<String>
    private var items: Set<String>

    // The key we're using to read/write in UserDefaults
    private let cocktailsSaveKey: SaveKey = .cocktails
    private let itemsSaveKey: SaveKey = .items

    // Variable that comes in handy for animations
    public var hasEffect: Bool = false
    
    init() {
        // Load our saved data
        if let encodedCocktailsData = UserDefaults.standard.data(forKey: cocktailsSaveKey.rawValue) {
            if let data = try? JSONDecoder().decode(Set<String>.self, from: encodedCocktailsData) {
                cocktails = data
                return
            }
        }
        if let encodedItemsData = UserDefaults.standard.data(forKey: itemsSaveKey.rawValue) {
            if let data = try? JSONDecoder().decode(Set<String>.self, from: encodedItemsData) {
                items = data
                return
            }
        }

        // Still here? Use an empty array
        self.cocktails = []
        self.items = []
    }

    // Returns true if our set contains this cocktail
    func containsCocktail(_ cocktail: Cocktail) -> Bool {
        cocktails.contains(cocktail.id)
    }
    // Returns true if our set contains this item
    func containsItem(_ item: Item) -> Bool {
        items.contains(item.name)
    }

    // Add cocktail to our set, updates all views, and saves the change
    func addCocktail(_ cocktail: Cocktail) {
        objectWillChange.send()
        cocktails.insert(cocktail.id)
        hasEffect.toggle()
        save()
    }
    
    // Add item to our set, updates all views, and saves the change
    func addItem(_ item: Item) {
        objectWillChange.send()
        items.insert(item.name)
        hasEffect.toggle()
        save()
    }


    // Remove cocktail from our set, updates all views, and saves the change
    func removeCocktail(_ cocktail: Cocktail) {
        objectWillChange.send()
        cocktails.remove(cocktail.id)
        hasEffect.toggle()
        save()
    }
    // Remove item from our set, updates all views, and saves the change
    func removeItem(_ item: Item) {
        objectWillChange.send()
        items.remove(item.name)
        hasEffect.toggle()
        save()
    }

    private func save() {
        // Write out our data
        if let data = try? JSONEncoder().encode(cocktails) {
            UserDefaults.standard.set(data, forKey: cocktailsSaveKey.rawValue)
        } else {
            fatalError("Unable to save cocktail!")
        }
        
        // Write out our data
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: itemsSaveKey.rawValue)
        } else {
            fatalError("Unable to item!")
        }
    }
}

extension FileManager {
    func getDocumentsDirectory() -> URL {
        // Find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        // Just send back the first one, which ought to be the only one
        return paths[0]
    }
}
