//
//  AppCommands.swift
//  DrinkoPro
//

import SwiftUI

/// The iPadOS and macOS menu bar. On macOS ⌘N already opens a new window, so New Cocktail uses
/// ⌥⌘N there. Commands go through `AppNavigationModel`, so they behave like tapping the
/// matching tab or toolbar button.
struct AppCommands: Commands {
    let appNavigationModel: AppNavigationModel

    var body: some Commands {
        CommandGroup(after: .newItem) {
            Button("New Cocktail", action: appNavigationModel.requestNewCocktail)
                #if os(macOS)
                .keyboardShortcut("n", modifiers: [.command, .option])
                #else
                .keyboardShortcut("n")
                #endif
            Button("New Category", action: appNavigationModel.requestNewCategory)
                .keyboardShortcut("n", modifiers: [.command, .shift])
        }

        CommandGroup(before: .sidebar) {
            Button("Learn", action: { appNavigationModel.selectedTab = .learn })
                .keyboardShortcut("1")
            Button("Cabinet", action: { appNavigationModel.selectedTab = .cabinet })
                .keyboardShortcut("2")
            Button("Cocktails", action: { appNavigationModel.selectedTab = .cocktails })
                .keyboardShortcut("3")
            Button("Tools", action: { appNavigationModel.selectedTab = .tools })
                .keyboardShortcut("4")
            Button("Settings", action: { appNavigationModel.selectedTab = .settings })
                .keyboardShortcut("5")
            Divider()
        }
    }
}
