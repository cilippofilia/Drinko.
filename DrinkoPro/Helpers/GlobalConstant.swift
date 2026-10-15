//
//  GlobalConstant.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 23/04/2023.
//

import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

let rowHeight: CGFloat = 45
let imageCornerRadius: CGFloat = 10
let imageFrameHeight: CGFloat = 280
/// The tallest a hero image that scales with its column's width (lessons, books) is allowed to
/// grow, so a wide iPad column doesn't produce an oversized banner.
let heroImageMaxHeight: CGFloat = 480
let libraryCardCornerRadius: CGFloat = 24
/// How round a polaroid's paper corners are (the library grid cards and the cocktail header).
let polaroidCornerRadius: CGFloat = 16
/// How round a polaroid's photo window is. Just softened, as on a print.
let polaroidPhotoCornerRadius: CGFloat = 6
/// The inset from a cocktail detail card's edges to its content, and the gap between cards.
let detailCardInset: CGFloat = 16
/// The gap between groups inside a cocktail detail card, like a card's header and its content,
/// or one procedure step and the next.
let detailCardGroupSpacing: CGFloat = 12
/// The gap between the rows of a list inside a cocktail detail card, like its ingredients.
let detailCardRowSpacing: CGFloat = 8
#if os(macOS)
let screenWidth: CGFloat = 350
#endif

let drinkoURL = URL(string: "https://apps.apple.com/gb/app/drinko/id6449893371")
let rateURL = URL(string: "itms-apps://apps.apple.com/gb/app/drinko/id6449893371?action=write-review")
