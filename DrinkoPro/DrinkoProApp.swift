//
//  DrinkoProApp.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 31/05/2023.
//

import SwiftData
import SwiftUI
import TipKit
@main
struct DrinkoProApp: App {
    @State private var favorites = Favorites()
    @State private var icons = DrinkoIcons()
    
    init() {
        #if DEBUG
        Tips.showAllTipsForTesting()
        #endif
        try? Tips.configure()
    }
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
        }
        .environment(favorites)
        .environment(icons)
        .modelContainer(for: [Category.self])
    }
}
