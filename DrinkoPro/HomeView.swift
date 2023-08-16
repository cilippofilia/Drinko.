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

            PostsList()
                .tag(PostsList.postsTag)
                .tabItem {
                    Label("Social", systemImage: "person.2")
                }

            PostsList(viewModel: PostsViewModel(filter: .liked))
//                .tag(PostsList.postsTag)
                .tabItem {
                    Label("Liked", systemImage: "heart.circle")
                }

            SettingsView()
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
    }
}
#endif
