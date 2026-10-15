//
//  AppCommands.swift
//  DrinkoPro
//

import SwiftUI

/// The iPadOS menu bar (and the hold-⌘ shortcut list): File › New… and View › section
/// shortcuts. Everything routes through `AppNavigationModel`, so a command behaves like
/// tapping the matching tab or toolbar button.
struct AppCommands: Commands {
    let appNavigationModel: AppNavigationModel

    var body: some Commands {
        CommandGroup(after: .newItem) {
            Button("New Cocktail", action: appNavigationModel.requestNewCocktail)
                .keyboardShortcut("n")
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
