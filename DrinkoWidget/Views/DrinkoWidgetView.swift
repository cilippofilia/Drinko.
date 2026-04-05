//
//  DrinkoWidgetView.swift
//  DrinkoWidget
//
//  Created by Filippo Cilia on 04/04/2026.
//

import SwiftUI
import UIKit
import WidgetKit

struct DrinkoWidgetView: View {
    // WidgetKit tells us which family is being rendered so we can add detail
    // as the widget gets more space.
    @Environment(\.widgetFamily) private var family

    let entry: DrinkoWidgetEntry

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                DrinkoWidgetSmallView(cocktail: entry.cocktail, imageData: entry.imageData)
            case .systemMedium:
                DrinkoWidgetMediumView(cocktail: entry.cocktail, imageData: entry.imageData)
            default:
                DrinkoWidgetMediumView(cocktail: entry.cocktail, imageData: entry.imageData)
            }
        }
        // The entire widget opens the matching cocktail detail when tapped.
        .widgetURL(entry.deepLinkURL)
        .containerBackground(.white, for: .widget)
    }
}
