//
//  Favorites.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 28/04/2023.
//

import SwiftUI

class Favorites: ObservableObject {
    // What the user has favourited
    private var cocktails: Set<String>

    // The key we're using to read/write in UserDefaults
    private let saveKey: String = "Cocktails"

    // Variable that comes in handy for animations
    public var hasEffect: Bool = false
    
    init() {
        // Load our saved data
        if let encodedCocktailsData = UserDefaults.standard.data(forKey: saveKey) {
            if let data = try? JSONDecoder().decode(Set<String>.self, from: encodedCocktailsData) {
                cocktails = data
                return
            }
        } 
        
        self.cocktails = []
    }

    // Returns true if our set contains this cocktail
    func contains(_ cocktail: Cocktail) -> Bool {
        cocktails.contains(cocktail.id)
    }

    // Add cocktail to our set, updates all views, and saves the change
    func add(_ cocktail: Cocktail) {
        objectWillChange.send()
        cocktails.insert(cocktail.id)
        hasEffect.toggle()
        save()
    }

    // Remove cocktail from our set, updates all views, and saves the change
    func remove(_ cocktail: Cocktail) {
        objectWillChange.send()
        cocktails.remove(cocktail.id)
        hasEffect.toggle()
        save()
    }

    private func save() {
        // Write out our favorite cocktails data
        if let data = try? JSONEncoder().encode(cocktails) {
            UserDefaults.standard.set(data, forKey: saveKey)
        } else {
            fatalError("Unable to save cocktail!")
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
