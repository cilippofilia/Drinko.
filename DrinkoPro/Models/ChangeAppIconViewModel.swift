//
//  ChangeAppIconViewModel.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 21/06/2024.
//

import Foundation
import UIKit

class ChangeAppIconViewModel: ObservableObject {
    @Published private(set) var selectedAppIcon: AppIcon?

    init() {
        if let iconName = UIApplication.shared.alternateIconName,
           let appIcon = AppIcon(rawValue: iconName) {
            selectedAppIcon = appIcon
        } else {
            selectedAppIcon = nil
        }
    }

    func updateAppIcon(to icon: AppIcon) {
        let previousAppIcon = selectedAppIcon
        selectedAppIcon = icon

        Task { @MainActor in
            guard UIApplication.shared.alternateIconName != icon.iconName else {
                /// No need to update since we're already using this icon.
                return
            }
            do {
                try await UIApplication.shared.setAlternateIconName(icon.iconName)
            } catch {
                /// We're only logging the error here and not actively handling the app icon failure since it's very unlikely to fail.
                print("Updating icon to \(String(describing: icon.iconName)) failed.")
                /// Restore previous app icon
                selectedAppIcon = previousAppIcon
            }
        }
    }
}

enum AppIcon: String, CaseIterable, Identifiable {
    case blackBlue      = "text-black-blue"
    case blueYellow     = "text-blue-yellow"
    case pride          = "text-pride"

    case blackWhite     = "text-black-white"
    case blueWhite      = "text-blue-white"
    case glow           = "glow"

    case black          = "original-black-white"
    case original       = "original"
    case rainbow        = "rainbow"

    var id: String { rawValue }
    var iconName: String? {
        switch self {
        case .original:
            /// `nil` is used to reset the app icon back to its primary icon.
            return nil
        default:
            return rawValue
        }
    }
    var description: String {
        rawValue.replacingOccurrences(of: "-", with: " ").replacingOccurrences(of: "text", with: "").capitalized
    }
    var preview: UIImage {
        UIImage(named: rawValue) ?? UIImage()
    }
}
