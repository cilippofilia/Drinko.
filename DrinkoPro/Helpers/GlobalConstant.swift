//
//  GlobalConstant.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 23/04/2023.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

let windowMinWidth: CGFloat = 600
let windowMinHeight: CGFloat = 300

let rowHeight: CGFloat = 45
let imageCornerRadius: CGFloat = 10
let imageFrameHeight: CGFloat = 280

#if os(iOS)
let screenWidth: CGFloat = UIScreen.main.bounds.width
#endif

// URLs inside the app
let twitterURL = URL(string: "https://x.com/the_drinko_app")
let instaURL = URL(string: "https://www.instagram.com/drinko_app")

let drinkoURL = URL(string: "https://apps.apple.com/gb/app/drinko/id6449893371")
let rateURL = URL(string: "itms-apps://apps.apple.com/gb/app/drinko/id6449893371?action=write-review")
