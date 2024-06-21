//
//  DrinkoProApp.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 31/05/2023.
//

import SwiftData
import SwiftUI
import TipKit

@main
struct DrinkoProApp: App {
    @State private var favorites = Favorites()

    init() {
        try? Tips.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
        }
        .environment(favorites)
        .modelContainer(for: Category.self)
    }
}
