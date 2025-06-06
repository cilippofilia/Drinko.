//
//  HomeView.swift
//  DrinkoProMac
//
//  Created by Filippo Cilia on 25/05/2025.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        TabView {
            LearnView()
                .tabItem {
                    Label("Learn", systemImage: "books.vertical")
                }

            CocktailsView()
                .tabItem {
                    Label("Cocktails", systemImage: "wineglass")
                }
        }
        .tabViewStyle(.sidebarAdaptable)
    }
}

#Preview {
    HomeView()
}
