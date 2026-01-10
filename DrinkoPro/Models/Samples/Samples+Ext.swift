//
//  Samples+Ext.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 20/04/2024.
//

import Foundation

// MARK: COCKTAIL
extension Cocktail {
#if DEBUG
    static let example = Cocktail(
        id: "mojito",
        name: "Corpse Reviver No.2",
        method: "shake & fine strain",
        glass: "shot",
        garnish: "-",
        ice: "-",
        extra: "absinthe-rinsed coupe",
        ingredients: [
            Ingredient(
                name: "london dry gin",
                quantity: 2.0,
                unit: "oz."),
            Ingredient(
                name: "cointreau",
                quantity: 0.5,
                unit: "oz."),
            Ingredient(
                name: "dry vermouth",
                quantity: 6,
                unit: "leaves"),
            Ingredient(
                name: "angostura bitters",
                quantity: 4,
                unit: "dashes")
        ]
    )
#endif
}

// MARK: PROCEDURE
extension Procedure {
#if DEBUG
    static let example = Procedure(
        id: "aperol-spritz",
        procedure: [
            Procedure.Steps(
                step: "Step 1",
                text: "Add all the ingredients into the cocktail shaker; a part from the red wine"
            ),
            Procedure.Steps(
                step: "Step 2",
                text: "Shake hard to emulsify your foaming agent. Add fresh cubed ice to the shaker, lock it, and shake hard for 8 to 12 seconds (until it is frosty outside)"
            ),
            Procedure.Steps(
                step: "Step 3",
                text: "Add cubed ice to the glass, fine strain the cocktail inside the glass and allow it to settle"
            ),
            Procedure.Steps(
                step: "Step 4",
                text: "Use a barspoon to float the red wine and enjoy!"
            )
        ]
    )
#endif
}

// MARK: HISTORY
extension History {
#if DEBUG
    static let example = History(
        id: "cosmopolitan",
        text: "Bartending legend Dale \"King Cocktail\" DeGroff discovered the Cosmopolitan at the Fog City Diner in San Francisco in the mid-1990s. He then perfected his own recipe for the cocktail, including his signature flamed orange zest twist as a garnish, while working at the Rainbow Rooms in Manhattan.\n\nDeGroff has never claimed to have invented the Cosmopolitan. In his 2002 book \"The Craft of Cocktail\", he explains that he popularized a definitive recipe that became widely accepted as the standard.\n\nThe Cosmopolitan gained immense popularity after it was frequently shown on the television show \"Sex and the City\", with the characters often sipping Cosmos and wondering why they ever stopped drinking them. The show's influence helped the cocktail become a household name."
    )
#endif
}

//MARK: LESSON
extension Lesson {
#if DEBUG
    static let example = Lesson(
        id: "equipment",
        title: "Example lesson",
        description: "This is an example to see how things will look.",
        body: [
            LessonContent(
                heading: "Cocktail shakers",
                content: "When purchasing a shaker, there are two main factors to consider: the style and the material it's made of (metal, stainless steel, plastic, etc.). The two most commonly found shakers are the 'Cobbler shaker,' which has three pieces, and the 'Boston shaker,' which has two pieces. I highly recommend the 'Boston shaker' because it's easy to use with one hand, making it look and sound good. Not only is it the most popular choice for professional bartenders because it's more effective with straining, but it's also easier to find spare parts for it due to its quality."
            ),
            LessonContent(
                heading: "Strainers",
                content: "There are three different types of strainers: 'Julep,' 'Hawthorn,' which prevents the chunks of ice from falling into the cocktail glass, and the fine strainer. The fine strainer (or tea strainer) catches all the small shards that come through. My preferred strainer is called the 'Calabrese Hawthorn strainer,' which is versatile and mainly used in combination with the fine strainer."
            ),
            LessonContent(
                heading: "Jiggers",
                content: "The jigger set I like to use consists of two vessels, each a double cone. The smaller one usually measures 25 ml and has marks on the inside for 15 ml, and the larger one measures 50 ml and has a mark for 35 ml."
            )
        ],
        hasVideo: true,
        videoURL: "https://www.youtube.com/watch?v=l7eut-nYIUc",
        videoID: "l7eut-nYIUc"
    )
#endif
}

// MARK: LESSON CONTENT
extension LessonContent {
#if DEBUG
    static let example = LessonContent(
        heading: "Cocktail shakers",
        content: "When purchasing a shaker, there are two main factors to consider: the style and the material it's made of (metal, stainless steel, plastic, etc.). The two most commonly found shakers are the 'Cobbler shaker,' which has three pieces, and the 'Boston shaker,' which has two pieces. I highly recommend the 'Boston shaker' because it's easy to use with one hand, making it look and sound good. Not only is it the most popular choice for professional bartenders because it's more effective with straining, but it's also easier to find spare parts for it due to its quality."
    )
#endif
}

// MARK: BOOK
extension Book {
#if DEBUG
    static let example = Book(
        id: "liquid-intelligence",
        title: "Liquid Intelligence",
        description: "Description of the book",
        summary: "\"Liquid Intelligence\" by Dave Arnold is a captivating exploration of cocktail science and mixology. Arnold reveals the secrets behind exceptional drinks, incorporating physics and chemistry principles into his innovative recipes and techniques. This book is a must-read for aspiring mixologists, offering a unique perspective on the art of crafting extraordinary libations.",
        author: "Example Author"
    )
#endif
}
