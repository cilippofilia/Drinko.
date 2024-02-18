//
//  Favorites.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 28/04/2023.
//

import SwiftUI

class Favorites: ObservableObject {
    // the actual cocktails the user has favourited
    private var cocktails: Set<String>
    // the key we're using to read/write in UserDefaults
    private let saveKey: String = "Favorites"
    // variable that comes in handy for animations
    public var hasEffect: Bool = false
    
    init() {
        // load our saved data
        if let encodedCocktailData = UserDefaults.standard.data(forKey: saveKey) {
            if let data = try? JSONDecoder().decode(Set<String>.self, from: encodedCocktailData) {
                cocktails = data
                return
            }
        }
        // still here? Use an empty array
        self.cocktails = []
    }

    // returns true if our set contains this cocktail
    func contains(_ cocktail: Cocktail) -> Bool {
        cocktails.contains(cocktail.id)
    }

    // adds the cocktail to our set, updates all views, and saves the change
    func add(_ cocktail: Cocktail) {
        objectWillChange.send()
        cocktails.insert(cocktail.id)
        hasEffect.toggle()
        save()
    }

    // removes the cocktail from our set, updates all views, and saves the change
    func remove(_ cocktail: Cocktail) {
        objectWillChange.send()
        cocktails.remove(cocktail.id)
        hasEffect.toggle()
        save()
    }

    private func save() {
        // write out our data
        if let data = try? JSONEncoder().encode(cocktails) {
            UserDefaults.standard.set(data, forKey: saveKey)
        } else {
            fatalError("Unable to save!")
        }
    }
}

extension FileManager {
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        // just send back the first one, which ought to be the only one
        return paths[0]
    }
}
