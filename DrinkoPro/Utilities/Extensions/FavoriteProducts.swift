//
//  FavoriteProducts.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 29/01/2024.
//

import Foundation

class FavoriteProducts: ObservableObject {
    // the actual cocktails the user has favourited
    private var products: Set<String>
    
    // the key we're using to read/write in UserDefaults
    private let saveKey = "Favorites"
    
    init() {
        // load our saved data
        if let encodedCocktailData = UserDefaults.standard.data(forKey: saveKey) {
            if let data = try? JSONDecoder().decode(Set<String>.self, from: encodedCocktailData) {
                products = data
                return
            }
        }
        // still here? Use an empty array
        self.products = []
    }

    // returns true if our set contains this cocktail
    func contains(_ product: Product) -> Bool {
        products.contains(product.name)
    }

    // adds the cocktail to our set, updates all views, and saves the change
    func add(_ product: Product) {
        objectWillChange.send()
        products.insert(product.name)
        save()
    }

    // removes the cocktail from our set, updates all views, and saves the change
    func remove(_ product: Product) {
        objectWillChange.send()
        products.remove(product.name)
        save()
    }

    private func save() {
        // write out our data
        if let data = try? JSONEncoder().encode(products) {
            UserDefaults.standard.set(data, forKey: saveKey)
        } else {
            fatalError("Unable to save!")
        }
    }
}
