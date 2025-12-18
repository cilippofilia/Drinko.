//
//  MacHomeView.swift
//  DrinkoMac
//
//  Created by Filippo Cilia on 16/12/2025.
//

import StoreKit
import SwiftUI

struct MacHomeView: View {
    // AppStorage is used to keep track of how many times the app has been opened
    @AppStorage("appUsageCounter") var appUsageCounter: Int = 0

    // SceneStorage is used to keep track of what tab was last used before closing the app
    @SceneStorage("selectedView") var selectedView: String?

    @Environment(\.requestReview) private var requestReview

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedView) {
                NavigationLink(value: LearnView.learnTag) {
                    Label("Learn", systemImage: "books.vertical")
                }

                NavigationLink(value: CocktailsView.cocktailsTag) {
                    Label("Cocktails", systemImage: "wineglass")
                }

                NavigationLink(value: CabinetView.cabinetTag) {
                    Label("Cabinet", systemImage: "cabinet")
                }

                NavigationLink(value: SettingsView.settingsTag) {
                    Label("Settings", systemImage: "gear")
                }
            }
            .navigationSplitViewColumnWidth(min: 140, ideal: 160, max: 180)
            .navigationTitle("Drinko.")
        } detail: {
            Group {
                if selectedView == LearnView.learnTag {
                    LearnView()
                } else if selectedView == CocktailsView.cocktailsTag {
                    CocktailsView()
                } else if selectedView == CabinetView.cabinetTag {
                    CabinetView()
                } else if selectedView == SettingsView.settingsTag {
                    SettingsView()
                } else {
                    // Default view when no selection
                    LearnView()
                }
            }
        }
        .onAppear {
            // Set default selection if none exists
            if selectedView == nil {
                selectedView = LearnView.learnTag
            }
            checkForReview()
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
    }
}

#Preview {
    MacHomeView()
}
