//
//  HomeView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 22/04/2023.
//

import SwiftUI

struct HomeView: View {
    // SceneStorage is used to keep track of what tab was last used before closing the app
    @SceneStorage("selectedView") var selectedView: String?
    @EnvironmentObject private var factory: ViewModelFactory

    var body: some View {
        TabView(selection: $selectedView) {
            NavigationView {
                LearnView()
            }
            .tag(LearnView.learnTag)
            .tabItem {
                Label("Learn", systemImage: "books.vertical")
            }

            NavigationView {
                CocktailsView()
            }
            .tag(CocktailsView.cocktailsTag)
            .tabItem {
                Label("Cocktails", systemImage: "wineglass")
            }

            NavigationView {
                PostsList(viewModel: factory.makePostsViewModel())
            }
            .tag(PostsList.postsTag)
            .tabItem {
                Label("Social", systemImage: "person.2")
            }

            NavigationView {
                PostsList(viewModel: factory.makePostsViewModel(filter: .favorites))
            }
            .tabItem {
                Label("Liked", systemImage: "heart.circle")
            }

            NavigationView {
                SettingsView()
            }
            .tag(SettingsView.settingsTag)
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
    }
}

#if DEBUG
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(ViewModelFactory.preview)
    }
}
#endif
