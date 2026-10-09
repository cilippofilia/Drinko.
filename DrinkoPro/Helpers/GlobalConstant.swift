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
#if os(macOS)
let screenWidth: CGFloat = 350
#endif

let drinkoURL = URL(string: "https://apps.apple.com/gb/app/drinko/id6449893371")
let rateURL = URL(string: "itms-apps://apps.apple.com/gb/app/drinko/id6449893371?action=write-review")
