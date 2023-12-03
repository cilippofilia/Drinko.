//
//  Lesson.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 27/04/2023.
//

import SwiftUI

struct Lesson: Codable, Equatable, Identifiable {
    let id: String
    var title: String
    var description: String
    var body: String
    var hasVideo: Bool?
    var videoURL: String?
    var videoID: String?

    var img: String {
        "https://raw.githubusercontent.com/cilippofilia/drinko-learn-pics/main/\(id).jpg"
    }

    #if DEBUG
    static let example = Lesson(id: "equipment",
                                title: "Example lesson",
                                description: "This is an example to see how things will look.",
                                body: "I want to start off with a big statement, you do not need everything straight away. Said so, let me help you out picking the right tools to start making awesome cocktails.\n\n• COCKTAIL SHAKERS\nThe two things to consider when buying a cocktail shaker are the style and the material.\nThere are two main style of shakers, a three-piece shaker, called Cobbler shaker, and a two-piece called Boston. The Cobbler is very hard to find a very well made one and is even hard to find spare parts, it tends to leak and it doesn't strain as quickly as a two-piece set up.\nMy suggestion is to go with a two-piece shaker with both parts made with metal, stainless steel is fine to start with too, simply because it is the most popular choice for professional bartenders, I use it at home and at work, is easier to use one-handed and looks and sounds good while shaking.",
                                hasVideo: true,
                                videoURL: "https://www.youtube.com/watch?v=l7eut-nYIUc",
                                videoID: "l7eut-nYIUc")
    #endif
}
