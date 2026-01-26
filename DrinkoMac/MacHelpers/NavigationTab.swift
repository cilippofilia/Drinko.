//
//  NavigationTab.swift
//  DrinkoDesktop
//
//  Created by Filippo Cilia on 10/01/2026.
//

import Foundation

enum NavigationTab: String, CaseIterable, Identifiable, Hashable {
    case learn
    case cocktails
    case cabinet
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .learn:
            "Learn"
        case .cocktails:
            "Cocktails"
        case .cabinet:
            "Cabinet"
        case .settings:
            "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .learn:
            "books.vertical.fill"
        case .cocktails:
            "wineglass.fill"
        case .cabinet:
            "cabinet.fill"
        case .settings:
            "gear"
        }
    }
}
