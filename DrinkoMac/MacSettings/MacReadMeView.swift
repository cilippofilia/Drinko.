//
//  MacReadMeView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 22/04/2023.
//

import SwiftUI

struct MacReadMeView: View {
    @Environment(\.horizontalSizeClass) var sizeClass

    private let compactColumn = [
        GridItem(
            .flexible(
                minimum: 240,
                maximum: 480
            ),
            spacing: 20,
            alignment: .leading
        )
    ]

    private let regularColumns = [
        GridItem(
            .flexible(
                minimum: 240,
                maximum: 480
            ),
            spacing: 20,
            alignment: .leading
        ),
        GridItem(
            .flexible(
                minimum: 240,
                maximum: 480
            ),
            spacing: 20,
            alignment: .leading
        )
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: sizeClass == .compact ? 10 : 20) {
                Text(readMeText)
                    .multilineTextAlignment(.leading)
                    .padding(.vertical)

                VStack(spacing: sizeClass == .compact ? 10 : 20) {
                    Text("Special thanks to:")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Drink selection")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    LazyVGrid(columns: sizeClass == .compact ? compactColumn : regularColumns,
                              spacing: sizeClass == .compact ? 10 : 20) {
                        CreditsCardView(
                            name: "Danil Nevsky 🍸",
                            brief: "Instagram: @cocktailman",
                            url: "https://instagram.com/cocktailman"
                        )
                        CreditsCardView(
                            name: "Christopher Lowder 🍸",
                            brief: "Instagram: @getlowdernow",
                            url: "https://instagram.com/getlowdernow"
                        )
                        CreditsCardView(
                            name: "Kevin Kos 🍸",
                            brief: "Instagram: @kevin_kos",
                            url: "https://www.instagram.com/kevin_kos"
                        )
                        CreditsCardView(
                            name: "Filippo Cilia 🍸",
                            brief: "Instagram: @cilippofilia",
                            url: "https://instagram.com/cilippofilia"
                        )
                    }
                    
                    Text("Photos & Videos")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    LazyVGrid(columns: sizeClass == .compact ? compactColumn : regularColumns,
                              spacing: sizeClass == .compact ? 10 : 20) {
                        CreditsCardView(
                            name: "Difford's Guide 🍸",
                            brief: "For discerning drinkers.",
                            url: "https://www.diffordsguide.com"
                        )
                        CreditsCardView(
                            name: "Simone Colombatto 🎥",
                            brief: "Instagram: @simonkol_",
                            url: "https://instagram.com/simonkol_"
                        )
                        CreditsCardView(
                            name: "The Beer Corner 🍺",
                            brief: "Instagram: @thebeercornercantu",
                            url: "https://instagram.com/thebeercornercantu"
                        )
                    }
                    
                    Text("Translations")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    LazyVGrid(columns: sizeClass == .compact ? compactColumn : regularColumns,
                              spacing: sizeClass == .compact ? 10 : 20) {
                        CreditsCardView(
                            name: "Filippo Cilia 🇮🇹",
                            brief: "Instagram: @cilippofilia",
                            url: "https://instagram.com/cilippofilia"
                        )
                        CreditsCardView(
                            name: "Arthur 🇫🇷",
                            brief: "X (Twitter): @AriOS_app",
                            url: "https://x.com/arios_app"
                        )
                        CreditsCardView(
                            name: "Nicolas 🇩🇪",
                            brief: "X (Twitter): @theduodev",
                            url: "https://x.com/theduodev"
                        )
                    }
                }
            }
            .padding(sizeClass == .compact ? .bottom : [.bottom, .horizontal])
            .frame(width: sizeClass == .compact ? screenWidth * 0.9 : nil)
        }
        .navigationTitle("Drinko.")
        .scrollIndicators(.hidden, axes: .vertical)
        .scrollBounceBehavior(.basedOnSize)
    }
}

#if DEBUG
#Preview {
    MacReadMeView()
}
#endif
