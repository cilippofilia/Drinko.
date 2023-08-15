//
//  DrinkoProApp.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 31/05/2023.
//

import Firebase
import SwiftUI

@main
struct DrinkoProApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
        }
    }
}
