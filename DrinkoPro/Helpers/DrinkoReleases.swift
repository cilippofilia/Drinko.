//
//  DrinkoReleases.swift
//  DrinkoPro
//

import AboutSection
import Foundation

/// Every release shown in the changelog, newest first. Bullets come from the App Store notes in `metadata/version`.
/// Mark a release `isMajor: true` to show its first three features on the What's New sheet.
let drinkoReleases: [Release] = {
    #if os(macOS)
    [
        Release(version: "3.2", isMajor: true, features: [
            Feature(
                title: "What Can I Make? shows every cocktail your Cabinet can make right now",
                detail: "Find it in Tools. Every ingredient counts, down to the juices, syrups and mixers.",
                systemImage: "cabinet"
            ),
            Feature(
                title: "Twists: cocktails you can make by swapping in a spirit you already own",
                detail: "Missing the base spirit? Drinko suggests one from your Cabinet that works instead.",
                systemImage: "arrow.triangle.swap"
            ),
            Feature(
                title: "Your own cocktails now switch units too, and ounces convert to the nearest 5 ml",
                detail: "Pick millilitres or ounces in Settings.",
                systemImage: "ruler"
            ),
            Feature(title: "Switch What Can I Make? between a list and a grid"),
            Feature(title: "A changelog in Settings shows what's new in every update"),
            Feature(title: "Request a feature right from Settings"),
            Feature(title: "Today's cocktail from Siri now includes shots"),
            Feature(title: "Delete buttons now appear in your language")
        ]),
        Release(version: "3.1", features: [
            Feature(title: "\"How do I make a Negroni in Drinko?\" Siri reads the ingredients, then the method when you're ready"),
            Feature(title: "Ask for today's cocktail, or say \"Surprise me in Drinko\""),
            Feature(title: "Add or remove favourites and restock your Cabinet by voice"),
            Feature(title: "Find cocktails from Spotlight and use every action in the Shortcuts app"),
            Feature(title: "New recipes and lessons arrive without waiting for an app update, and stay available offline"),
            Feature(title: "Sharing a drink comes with a fresh message each time")
        ]),
        Release(version: "3.0", features: [
            Feature(title: "Add a photo to your own cocktails, turn it into a sticker, or pick a card colour"),
            Feature(title: "36 new shots, including the Ferrari Shot, plus Campari classics like the Milano-Torino and Garibaldi"),
            Feature(title: "Favourites, recently viewed drinks and settings sync with your iPhone and iPad through iCloud"),
            Feature(title: "File › New and View shortcuts to create cocktails and switch sections from the keyboard"),
            Feature(title: "A single sidebar, library and detail view, with Remove Ads always one click away"),
            Feature(title: "Redesigned library cards and cocktail pages"),
            Feature(title: "Search by ingredient: type \"gin\" to find every drink that uses it"),
            Feature(title: "Choose your recipe units in Settings")
        ])
    ]
    #else
    [
        Release(version: "3.2", isMajor: true, features: [
            Feature(
                title: "What Can I Make? shows every cocktail your Cabinet can make right now",
                detail: "Find it in Tools. Every ingredient counts, down to the juices, syrups and mixers.",
                systemImage: "cabinet"
            ),
            Feature(
                title: "Twists: cocktails you can make by swapping in a spirit you already own",
                detail: "Missing the base spirit? Drinko suggests one from your Cabinet that works instead.",
                systemImage: "arrow.triangle.swap"
            ),
            Feature(
                title: "Your own cocktails now switch units too, and ounces convert to the nearest 5 ml",
                detail: "Pick millilitres or ounces in Settings.",
                systemImage: "ruler"
            ),
            Feature(title: "Switch What Can I Make? between a list and a grid"),
            Feature(title: "A step-by-step guide to adding the Drinko widget, in Settings"),
            Feature(title: "A changelog in Settings shows what's new in every update"),
            Feature(title: "Request a feature right from Settings"),
            Feature(title: "The cocktail of the day, on the widget and from Siri, now includes shots"),
            Feature(title: "Delete buttons now appear in your language")
        ]),
        Release(version: "3.1", features: [
            Feature(title: "\"How do I make a Negroni in Drinko?\" Siri reads the ingredients, then the method when you're ready"),
            Feature(title: "Ask for today's cocktail, or say \"Surprise me in Drinko\""),
            Feature(title: "Add or remove favourites by voice, or tap the new heart right on the widget"),
            Feature(title: "Tell Siri which bottles you just bought and they land in your Cabinet"),
            Feature(title: "Find cocktails from Spotlight and use every action in the Shortcuts app"),
            Feature(title: "New recipes and lessons arrive without waiting for an app update, and stay available offline"),
            Feature(title: "Shared recipe cards now open every built-in cocktail in the App Clip"),
            Feature(title: "Sharing a drink comes with a fresh message each time")
        ]),
        Release(version: "3.0", features: [
            Feature(title: "Add a photo to your own cocktails, turn it into a sticker, or pick a card colour"),
            Feature(title: "Share any recipe as a beautiful card — friends can open it instantly with an App Clip, no download needed"),
            Feature(title: "36 new shots, including the Ferrari Shot, plus Campari classics like the Milano-Torino and Garibaldi"),
            Feature(title: "Favourites, recently viewed drinks and settings now sync across your iPhone, iPad and Mac with iCloud"),
            Feature(title: "Ready for iPhone Duo, and for multitasking alongside your other apps"),
            Feature(title: "Redesigned Cocktails and Learn: switch between cards and list, and jump back in from your recently viewed drinks"),
            Feature(title: "Cocktail pages are now tidy, collapsible cards for history, ingredients and method"),
            Feature(title: "Search by ingredient: type \"gin\" to find every drink that uses it"),
            Feature(title: "A new Tools tab brings the calculators together, including a live ABV calculator"),
            Feature(title: "Choose your recipe units in Settings; they start out matching your region"),
            Feature(title: "On iPad: a new sidebar, plus keyboard shortcuts for creating cocktails and switching tabs"),
            Feature(title: "Fewer interruptions: promotions appear less often")
        ])
    ]
    #endif
}()
