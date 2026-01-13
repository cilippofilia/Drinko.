//
//  HomeView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 22/04/2023.
//

import StoreKit
import SwiftUI

struct HomeView: View {
    // AppStorage is used to keep track of how many times the app has been opened
    @AppStorage("appUsageCounter") var appUsageCounter: Int = 0

    // SceneStorage is used to keep track of what tab was last used before closing the app
    @SceneStorage("selectedView") var selectedView: String?
    
    @Environment(\.requestReview) private var requestReview

    var body: some View {
        TabView(selection: $selectedView) {
            Tab("Learn", systemImage: "books.vertical", value: LearnView.learnTag) {
                NavigationStack {
                    LearnView()
                }
            }
            
            Tab("Cocktails", systemImage: "wineglass", value: CocktailsView.cocktailsTag) {
                CocktailsView()
            }
            
            Tab("Cabinet", systemImage: "cabinet", value: CabinetView.cabinetTag) {
                CabinetView()
            }

            #if os(iOS)
            Tab("Settings", systemImage: "gear", value: SettingsView.settingsTag) {
                SettingsView()
            }
            #endif
        }
        .onAppear(perform: checkForReview)
    }

    // Get current Version of the App
    func getCurrentAppVersion() -> String {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return "Unknown"
        }
        return version
    }

    func checkForReview() {
        appUsageCounter += 1

        if appUsageCounter == 3 || appUsageCounter % 15 == 0 {
            if appUsageCounter > 103 { appUsageCounter = 0 }
            requestReview()
        }
    }
}

#if DEBUG
#Preview {
    HomeView()
        .environment(Favorites())
}
#endif
