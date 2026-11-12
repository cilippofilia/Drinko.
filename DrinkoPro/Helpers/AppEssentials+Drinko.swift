//
//  AppEssentials+Drinko.swift
//  DrinkoPro
//

import AboutSection
import Foundation

/// Drinko's details for the About rows, changelog and What's New sheet.
let drinkoAppInfo = AppInfo(appStoreID: "6449893371", developerEmail: "cilia.filippo.dev@gmail.com")

/// Drinko's header and extra step on top of the package's standard widget instructions.
let drinkoWidgetGuide = WidgetGuide(
    intro: "Add Drinko's “Cocktail of the Day” widget to your Home Screen for daily inspiration, right at a glance.",
    extraSteps: [
        WidgetGuideStep(
            systemImage: "slider.horizontal.3",
            title: "Customize it",
            detail: "Touch and hold the widget, then choose Edit Widget to change the drink source or show and hide ingredients."
        )
    ]
)
