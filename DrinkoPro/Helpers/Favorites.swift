//
//  Favorites.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 28/04/2023.
//

import SwiftUI

@MainActor
@Observable
class Favorites {
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
        cocktails.insert(cocktail.id)
        hasEffect.toggle()
        save()
    }

    // Remove cocktail from our set, updates all views, and saves the change
    func remove(_ cocktail: Cocktail) {
        cocktails.remove(cocktail.id)
        hasEffect.toggle()
        save()
    }

    private func save() {
        // Write out our favorite cocktails data
        guard let data = try? JSONEncoder().encode(cocktails) else {
            print("Warning: Unable to save favorite cocktails")
            return
        }
        UserDefaults.standard.set(data, forKey: saveKey)
    }
}
