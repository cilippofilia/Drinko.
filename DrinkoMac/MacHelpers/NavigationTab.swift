//
//  NavigationTab.swift
//  DrinkoMac
//
//  Created by Filippo Cilia on 10/01/2026.
//

import Foundation

enum NavigationTab: String, CaseIterable, Identifiable, Hashable {
    case learn
    case cabinet
    case cocktails
    case tools
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
        case .tools:
            "Tools"
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
        case .tools:
            "wrench.and.screwdriver.fill"
        case .settings:
            "gear"
        }
    }
}
