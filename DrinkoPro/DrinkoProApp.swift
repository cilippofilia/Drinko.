//
//  DrinkoProApp.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 31/05/2023.
//

import SwiftData
import SwiftUI

@main
struct DrinkoProApp: App {
    @State private var favorites = Favorites()
    @State private var icons = DrinkoIcons()
    @State private var storeManager = StoreManager()
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environment(storeManager)
                .task {
                    await storeManager.updatePurchasedProducts()
                }
        }
        .environment(favorites)
        .environment(icons)
        .modelContainer(for: [Category.self])
    }
}
