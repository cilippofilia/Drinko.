//
//  ScreenSizeMargins.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 23/04/2023.
//

import SwiftUI

let deviceWidth = UIScreen.main.bounds.size.width /// Device width size
let compactScreenWidth = deviceWidth / 1.1 /// iPhone padded view
let regularScreenWidth = deviceWidth / 1.3 /// iPad padded view

// URLs inside the app
let twitterDevURL = URL(string: "https://twitter.com/fcilia_dev/")
let drinkoURL = URL(string: "https://apps.apple.com/gb/app/drinko-cocktail-recipes-app/id6449893371")
let rateURL = URL(string: "itms-apps://apps.apple.com/gb/app/drinko-cocktail-recipes-app/id6449893371?action=write-review")
