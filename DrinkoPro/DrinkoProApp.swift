//
//  DrinkoProApp.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 31/05/2023.
//

import AppIntents
import SwiftData
import SwiftUI

@main
struct DrinkoProApp: App {
    @State private var favorites: Favorites
    @State private var cocktailsViewModel: CocktailsViewModel
    @State private var lessonsViewModel: LessonsViewModel
    @State private var appNavigationModel: AppNavigationModel
    @State private var recentsStore: RecentsStore
    #if os(iOS) || os(macOS)
    @State private var removeAdsStore = RemoveAdsStore()
    @State private var crossPromoSignal = CrossPromoSignal()
    #endif

    private let modelContainer: ModelContainer
    // Mirrors favorites, recents and settings to iCloud. Kept for the app's lifetime.
    private let cloudSync: CloudSync
    // Keeps Spotlight and Siri's cocktail list current. Kept for the app's lifetime.
    private let intentIndexer = CocktailIntentIndexer()
    // Loads cached content at launch and refreshes it from GitHub in the background.
    @State private var contentStore: ContentStore

    init() {
        LearnCollapseMigration.runIfNeeded()
        ContentCacheMigration.runIfNeeded()

        let favorites = Favorites()
        let recentsStore = RecentsStore()
        let contentStore = ContentStore()
        let snapshot = contentStore.initialSnapshot()
        _contentStore = State(initialValue: contentStore)
        let cocktailsViewModel = CocktailsViewModel(snapshot: snapshot)
        let appNavigationModel = AppNavigationModel()
        _cocktailsViewModel = State(initialValue: cocktailsViewModel)
        _appNavigationModel = State(initialValue: appNavigationModel)
        _lessonsViewModel = State(initialValue: LessonsViewModel(snapshot: snapshot))
        _favorites = State(initialValue: favorites)
        _recentsStore = State(initialValue: recentsStore)

        cloudSync = CloudSync { _ in
            favorites.reload()
            recentsStore.reload()
        }
        cloudSync.start()

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

        // Loads user cocktails so Siri can find them without the Cocktails tab appearing.
        cocktailsViewModel.configure(modelContext: modelContainer.mainContext)

        // Re-index whenever the drink lists change, and once now for the launch list.
        let indexer = intentIndexer
        cocktailsViewModel.onDrinksChanged = { drinks in
            Task { await indexer.update(with: drinks) }
        }
        let launchDrinks = cocktailsViewModel.listOfAllDrinks
        Task { await indexer.update(with: launchDrinks) }

        // The same instances the UI uses, for App Intents to resolve with @Dependency.
        let registeredContainer = modelContainer
        AppDependencyManager.shared.add { cocktailsViewModel }
        AppDependencyManager.shared.add { favorites }
        AppDependencyManager.shared.add { appNavigationModel }
        AppDependencyManager.shared.add { registeredContainer }
    }
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .task {
                    if let snapshot = await contentStore.refreshIfNeeded() {
                        cocktailsViewModel.apply(snapshot)
                        lessonsViewModel.apply(snapshot)
                    }
                }
            #if os(macOS)
                .frame(
                    minWidth: 720,
                    minHeight: 480
                )
            #endif
            .onOpenURL { url in
                appNavigationModel.handle(url: url)
            }
            .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { activity in
                guard let url = activity.webpageURL else { return }
                appNavigationModel.handle(url: url)
            }
        }
        .environment(favorites)
        .environment(cocktailsViewModel)
        .environment(lessonsViewModel)
        .environment(contentStore)
        .environment(appNavigationModel)
        .environment(recentsStore)
        #if os(iOS) || os(macOS)
        .environment(removeAdsStore)
        .environment(crossPromoSignal)
        #endif
        .modelContainer(modelContainer)
        #if os(iOS) || os(macOS)
        .commands {
            AppCommands(appNavigationModel: appNavigationModel)
        }
        #endif
    }
}
