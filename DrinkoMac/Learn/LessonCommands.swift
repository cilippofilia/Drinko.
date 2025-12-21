//
//  LessonCommands.swift
//  DrinkoMac
//
//  Created by Filippo Cilia on 19/12/2025.
//

import Foundation
import SwiftUI

struct LessonCommands: Commands {
    @FocusedBinding(\.selectedLesson) var selectedLesson

    var body: some Commands {
        SidebarCommands()
        CommandMenu("Command Lesson") {
            Button(action: {
                print(">>> Tapping test button")
            }) {
                Label("TEST", systemImage: "info")
            }
            .keyboardShortcut("f", modifiers: [.shift, .option])
        }
    }
}

private struct SelectedLessonKey: FocusedValueKey {
    typealias Value = Binding<Lesson>
}


extension FocusedValues {
    var selectedLesson: Binding<Lesson>? {
        get { self[SelectedLessonKey.self] }
        set { self[SelectedLessonKey.self] = newValue }
    }
}

