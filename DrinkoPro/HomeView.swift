//
//  HomeView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 22/04/2023.
//

import CoreData
import StoreKit
import SwiftUI

struct HomeView: View {
    // AppStorage is used to keep track of how many times the app has been opened
    @AppStorage("appUsageCounter") var appUsageCounter: Int = 0
    @EnvironmentObject var dataController: DataController
    // SceneStorage is used to keep track of what tab was last used before closing the app
    @SceneStorage("selectedView") var selectedView: String?

    var body: some View {
        TabView(selection: $selectedView) {
            LearnView()
                .tag(LearnView.learnTag)
                .tabItem {
                    Label("Learn", systemImage: "books.vertical")
                }

            CocktailsView()
                .tag(CocktailsView.cocktailsTag)
                .tabItem {
                    Label("Cocktails", systemImage: "wineglass")
                }

            CabinetView(dataController: dataController)
                .tag(CabinetView.cabinetViewTag)
                .tabItem {
                    Label("Cabinet", systemImage: "cabinet")
                }

            SettingsView()
                .tag(SettingsView.settingsTag)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .onAppear(perform: checkForReview)
    }

    // Get current Version of the App
    func getCurrentAppVersion() -> String {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
        let version = (appVersion as! String)

        return version
    }

    func checkForReview() {
        guard let scene = UIApplication.shared.currentScene else { return }
        appUsageCounter += 1

        if appUsageCounter == 3 || appUsageCounter % 5 == 0 {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}

extension UIApplication {
    var currentScene: UIWindowScene? {
        connectedScenes
            .first { $0.activationState == .foregroundActive } as? UIWindowScene
    }
}

#if DEBUG
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(DataController())
    }
}
#endif
