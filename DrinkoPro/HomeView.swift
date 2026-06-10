//
//  HomeView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 22/04/2023.
//

import StoreKit
import SwiftUI

struct HomeView: View {
    @Environment(AppNavigationModel.self) private var appNavigationModel
    // AppStorage is used to keep track of how many times the app has been opened
    @AppStorage("appUsageCounter") var appUsageCounter: Int = 0
    // AppStorage flag so the widget tutorial sheet only ever auto-presents once
    @AppStorage("widgetTutorialShown") var widgetTutorialShown: Bool = false
    // SceneStorage is used to keep track of what tab was last used before closing the app
    @SceneStorage("selectedView") var selectedView: String?
    @Environment(\.requestReview) private var requestReview

    @State private var showingWidgetTutorial = false

    var body: some View {
        TabView(selection: selectedViewBinding) {
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
            Tab("Settings", systemImage: "gear", value: SettingsView.settingsTag) {
                SettingsView()
            }
        }
        .onAppear(perform: checkForReview)
        .sheet(isPresented: $showingWidgetTutorial) {
            NavigationStack {
                WidgetTutorialView()
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                showingWidgetTutorial = false
                            }
                        }
                    }
            }
        }
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

        // Show the widget tutorial once, after the user has had a few app
        // opens. The threshold of 4 avoids overlapping with the review
        // prompt at 3, and `>=` ensures users already past 4 still see it.
        if appUsageCounter >= 4 && !widgetTutorialShown {
            widgetTutorialShown = true
            showingWidgetTutorial = true
        }
    }

    private var selectedViewBinding: Binding<String?> {
        Binding(
            get: {
                appNavigationModel.selectedTab ?? selectedView
            },
            set: { newValue in
                selectedView = newValue
                appNavigationModel.selectedTab = newValue
            }
        )
    }
}

#if DEBUG
#Preview {
    HomeView()
        .drinkoPreviewEnvironment()
}
#endif
