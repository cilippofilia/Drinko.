//
//  DrinkoProApp.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 31/05/2023.
//

import SwiftData
import SwiftUI

@main
struct DrinkoProApp: App {
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
        }
        .environmentObject(IconModel())
        .modelContainer(for: [
            Category.self
        ])
    }
}
