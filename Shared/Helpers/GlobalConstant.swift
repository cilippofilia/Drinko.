//
//  GlobalConstant.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 23/04/2023.
//

import SwiftUI

let deviceWidth = UIScreen.main.bounds.size.width /// Device width size
let compactScreenWidth = deviceWidth * 0.9 /// iPhone padded view
let regularScreenWidth = deviceWidth * 0.7 /// iPad padded view
let rowHeight: CGFloat = 45
let imageCornerRadius: CGFloat = 10
let imageFrameHeight: CGFloat = 280

// URLs inside the app
let twitterURL = URL(string: "https://x.com/the_drinko_app")
let instaURL = URL(string: "https://www.instagram.com/drinko_app")

let drinkoURL = URL(string: "https://apps.apple.com/gb/app/drinko/id6449893371")
let rateURL = URL(string: "itms-apps://apps.apple.com/gb/app/drinko/id6449893371?action=write-review")
