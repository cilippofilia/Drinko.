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
    @State private var cocktailsViewModel = CocktailsViewModel()
    @State private var lessonsViewModel = LessonsViewModel()

    private let modelContainer: ModelContainer

    init() {
        do {
            let config = ModelConfiguration(cloudKitDatabase: .automatic)
            modelContainer = try ModelContainer(
                for: Category.self,
                Item.self,
                configurations: config
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
        }
        .environment(favorites)
        .environment(cocktailsViewModel)
        .environment(lessonsViewModel)
        .modelContainer(modelContainer)
    }
}
