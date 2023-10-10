//
//  ReadMeView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 22/04/2023.
//

import SwiftUI

struct ReadMeView: View {
    @Environment(\.horizontalSizeClass) var sizeClass

    @State private var text: LocalizedStringKey =
"""
Welcome to the exciting world of cocktails! This app is your ultimate guide to crafting the perfect drink, whether you're a seasoned bartender or just starting as a home enthusiast. It's a perfect blend of my personal experience behind the bar, insights from friends and colleagues, and information collected from reliable sources on the internet and various books.

But, let's face it, taste is subjective, and there's no one-size-fits-all approach to making cocktails. However, this app will be your trusty companion to help you discover new recipes, perfect your favorites, and even create your signature cocktail.

From refreshing tropical blends to sophisticated sips, we've got you covered. You'll find everything from classic cocktails to modern twists, so get ready to impress your guests with your newfound mixology skills.

But, at the end of the day, the most important thing is that you enjoy the cocktail sitting in front of you. So, use this app as a guideline, experiment with different ingredients and techniques, and most importantly, have fun! Who knows, you might even uncover some professional bartending tips and tricks along the way.

So, are you ready to shake things up and craft some delicious drinks? Let's raise a glass and cheers to endless possibilities!
"""
    private let compactColumn = [
        GridItem(.flexible(minimum: 240,
                           maximum: 480),
                 spacing: 20,
                 alignment: .leading),
    ]

    private let regularColumns = [
        GridItem(.flexible(minimum: 240,
                           maximum: 480),
                 spacing: 20,
                 alignment: .leading),

        GridItem(.flexible(minimum: 240,
                           maximum: 480),
                 spacing: 20,
                 alignment: .leading),
    ]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: sizeClass == .compact ? 10 : 20) {
                Text(text)
                    .multilineTextAlignment(.leading)
                    .padding(.vertical)

                VStack(spacing: sizeClass == .compact ? 10 : 20) {
                    Text("Special thanks to:")
                        .frame(maxWidth: .infinity, alignment: .leading)

                    LazyVGrid(columns: sizeClass == .compact ? compactColumn : regularColumns,
                              spacing: sizeClass == .compact ? 10 : 20) {
                        CreditsCardView(image: "heart.fill",
                                        name: "Danil Nevsky 🍸",
                                        brief: "Instagram: @cocktailman",
                                        url: "https://instagram.com/cocktailman")

                        CreditsCardView(image: "heart.fill",
                                        name: "Christopher Lowder 🍸",
                                        brief: "Instagram: @getlowdernow",
                                        url: "https://instagram.com/getlowdernow")

                        CreditsCardView(image: "heart.fill",
                                        name: "Simone Colombatto 🎥",
                                        brief: "Instagram: @simonkol_",
                                        url: "https://instagram.com/simonkol_?igshid=MzRlODBiNWFlZA==")

                        CreditsCardView(image: "heart.fill",
                                        name: "The Beer Corner 🍺",
                                        brief: "Instagram: @thebeercornercantu",
                                        url: "https://instagram.com/thebeercornercantu?igshid=MzRlODBiNWFlZA==")

                        CreditsCardView(image: "heart.fill",
                                        name: "Difford's Guide 🍸",
                                        brief: "For discerning drinkers.",
                                        url: "https://www.diffordsguide.com")

                        CreditsCardView(image: "heart.fill",
                                        name: "Filippo Cilia 🇮🇹 / 🍸",
                                        brief: "Instagram: @cilippofilia",
                                        url: "https://instagram.com/cilippofilia")

                        CreditsCardView(image: "heart.fill",
                                        name: "Arthur 🇫🇷",
                                        brief: "X (Twitter): @AriOS_app",
                                        url: "https://x.com/arios_app?s=21&t=GH4SWEVHVFi_peVsOSu5vA")

                        CreditsCardView(image: "heart.fill",
                                        name: "Nicolas 🇩🇪",
                                        brief: "X (Twitter): @theduodev",
                                        url: "https://x.com/theduodev?s=21&t=GH4SWEVHVFi_peVsOSu5vA")
                    }
                }
            }
//            .frame(width: sizeClass == .compact ? compactScreenWidth : regularScreenWidth)
            .padding(sizeClass == .compact ? .bottom : [.bottom, .horizontal])
        }
        .navigationBarTitle("Drinko")
    }
}

#Preview {
    ReadMeView()
}
