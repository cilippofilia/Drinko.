//
//  HomeView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 22/04/2023.
//

import SwiftUI

struct HomeView: View {
// SceneStorage is used to keep track of what tab
// was last used before closing the app
    @SceneStorage("selectedView") var selectedView: String?

    var body: some View {
        TabView(selection: $selectedView) {
            LearnView()
                .tag(LearnView.learnTag)
                .tabItem {
                    Image(systemName: "books.vertical")
                    Text("Learn")
                }

            CocktailsView()
                .tag(CocktailsView.cocktailsTag)
                .tabItem {
                    Image(systemName: "wineglass")
                    Text("Cocktails")
                }

//            NewsView()
//                .tag(NewsView.newsTag)
//                .tabItem {
//                    Image(systemName: "newspaper")
//                    Text("News")
//                }

//            CabinetView()
//                .tag(CabinetView.cabinetTag)
//                .tabItem {
//                    Image(systemName: "cabinet")
//                    Text("Cabinet")
//                }

            SettingsView()
                .tag(SettingsView.settingsTag)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
