//
//  LibraryCardCaptionLines.swift
//  DrinkoPro
//

import SwiftUI

extension EnvironmentValues {
    /// How many lines a library grid card reserves for its title. Every card reserves the same,
    /// so cards line up in rows; a library whose titles are short (like cocktail names) sets
    /// one line so its cards aren't left with an empty line.
    @Entry var libraryCardCaptionLines = 2
}
