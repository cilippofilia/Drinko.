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
    @State private var cocktailsViewModel = CocktailsViewModel()
    @State private var lessonsViewModel = LessonsViewModel()
    #if os(macOS)
    @State private var macTabViewModel = MacTabViewModel()
    #endif
    init() {
        try? Tips.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
        }
        .environment(favorites)
        .environment(cocktailsViewModel)
        .environment(lessonsViewModel)
        #if os(macOS)
        .environment(macTabViewModel)
        #endif
        #if os(iOS)
        .modelContainer(for: [Category.self, Item.self])
        #endif
    }
}
