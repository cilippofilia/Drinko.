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

let windowMinWidth: CGFloat = 750
let windowMinHeight: CGFloat = 350

let rowHeight: CGFloat = 45
let imageCornerRadius: CGFloat = 10
let imageFrameHeight: CGFloat = 280
#if os(iOS)
let screenWidth: CGFloat = UIScreen.main.bounds.width
#elseif os(macOS)
let screenWidth: CGFloat = 350
#endif

let lovelyText = "This app was made with ❤️ by Filippo Cilia 🇮🇹"

// URLs inside the app
let twitterURL = URL(string: "https://x.com/fcilia_dev")
let instaURL = URL(string: "https://www.instagram.com/cilippofilia")

let drinkoURL = URL(string: "https://apps.apple.com/gb/app/drinko/id6449893371")
let rateURL = URL(string: "itms-apps://apps.apple.com/gb/app/drinko/id6449893371?action=write-review")
