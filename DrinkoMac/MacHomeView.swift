//
//  MacHomeView.swift
//  DrinkoMac
//
//  Created by Filippo Cilia on 10/01/2026.
//

import SwiftUI

struct MacHomeView: View {
    @State private var selectedTab: String = ""

    var body: some View {
        NavigationSplitView(
            columnVisibility: .constant(.all),
            sidebar: {
                List(selection: $selectedTab) {
                    Label("Learn", systemImage: "books.vertical.fill")
                        .tag("learn")
                    Label("Cocktails", systemImage: "wineglass.fill")
                        .tag("cocktails")
                    Label("Cabinet", systemImage: "cabinet.fill")
                        .tag("cabinet")
                    Label("Settings", systemImage: "gear")
                        .tag("settings")
                }
            },
            content: {
                Text("\(selectedTab) Content")
            },
            detail: {
                Text("\(selectedTab) Content Detail")
            }
        )
    }
}

#Preview {
    MacHomeView()
}
