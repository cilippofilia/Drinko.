//
//  HomeView.swift
//  DrinkoProMac
//
//  Created by Filippo Cilia on 24/05/2025.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        TabView {
            LearnView()
                .tabItem {
                    Label("Learn", systemImage: "book.fill")
                }

            ResourcesView()
                .tabItem {
                    Label("Resources", systemImage: "folder.fill")
                }
        }
        .frame(minWidth: 750, minHeight: 400)
    }
}

struct ResourcesView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "folder")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundStyle(.blue)
            Text("Resources")
                .font(.largeTitle)
                .bold()
            Text("More content coming soon.")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


#Preview {
    HomeView()
}
