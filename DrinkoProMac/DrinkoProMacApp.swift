//
//  DrinkoProMacApp.swift
//  DrinkoProMac
//
//  Created by Filippo Cilia on 24/05/2025.
//

import SwiftUI

@main
struct DrinkoProMacApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
                .frame(minWidth: windowMinWidth, minHeight: windowMinHeight)
        }
    }
}
