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
    var body: [LessonContent]
    
    var hasVideo: Bool?
    var videoURL: String?
    var videoID: String?

    var img: String {
        "https://raw.githubusercontent.com/cilippofilia/drinko-learn-pics/main/\(id).jpg"
    }

    struct LessonContent: Codable, Equatable, Identifiable {
        var id: String { heading }
        let heading: String
        let content: String
        
        #if DEBUG
        static let example = LessonContent(heading: "Cocktail shakers",
                                           content: "When purchasing a shaker, there are two main factors to consider: the style and the material it's made of (metal, stainless steel, plastic, etc.). The two most commonly found shakers are the 'Cobbler shaker,' which has three pieces, and the 'Boston shaker,' which has two pieces. I highly recommend the 'Boston shaker' because it's easy to use with one hand, making it look and sound good. Not only is it the most popular choice for professional bartenders because it's more effective with straining, but it's also easier to find spare parts for it due to its quality.")
        #endif
    }
    
    #if DEBUG
    static let example = Lesson(id: "equipment",
                                title: "Example lesson",
                                description: "This is an example to see how things will look.",
                                body: [
                                    LessonContent(heading: "Cocktail shakers",
                                                  content: "When purchasing a shaker, there are two main factors to consider: the style and the material it's made of (metal, stainless steel, plastic, etc.). The two most commonly found shakers are the 'Cobbler shaker,' which has three pieces, and the 'Boston shaker,' which has two pieces. I highly recommend the 'Boston shaker' because it's easy to use with one hand, making it look and sound good. Not only is it the most popular choice for professional bartenders because it's more effective with straining, but it's also easier to find spare parts for it due to its quality."),
                                    LessonContent(heading: "Strainers",
                                                  content: "There are three different types of strainers: 'Julep,' 'Hawthorn,' which prevents the chunks of ice from falling into the cocktail glass, and the fine strainer. The fine strainer (or tea strainer) catches all the small shards that come through. My preferred strainer is called the 'Calabrese Hawthorn strainer,' which is versatile and mainly used in combination with the fine strainer."),
                                    LessonContent(heading: "Jiggers",
                                                  content: "The jigger set I like to use consists of two vessels, each a double cone. The smaller one usually measures 25 ml and has marks on the inside for 15 ml, and the larger one measures 50 ml and has a mark for 35 ml.")
                                ],
                                hasVideo: true,
                                videoURL: "https://www.youtube.com/watch?v=l7eut-nYIUc",
                                videoID: "l7eut-nYIUc")
    #endif
}
