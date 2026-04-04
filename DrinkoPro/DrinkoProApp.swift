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
    @State private var appNavigationModel = AppNavigationModel()

    private let modelContainer: ModelContainer

    init() {
        do {
            let config = ModelConfiguration(cloudKitDatabase: .automatic)
            modelContainer = try ModelContainer(
                for: Category.self,
                Item.self,
                UserCreatedCocktail.self,
                UserIngredient.self,
                UserProcedure.self,
                UserProcedureStep.self,
                configurations: config
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
            #if os(macOS)
                .frame(
                    minWidth: 720,
                    minHeight: 480
                )
            #endif
            .onOpenURL { url in
                appNavigationModel.handle(url: url)
            }
        }
        .environment(favorites)
        .environment(cocktailsViewModel)
        .environment(lessonsViewModel)
        .environment(appNavigationModel)
        .modelContainer(modelContainer)
    }
}
