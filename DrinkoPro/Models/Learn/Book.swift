//
//  Book.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 28/06/2023.
//

import Foundation

struct Book: Codable, Equatable, Identifiable {
    let id: String
    var title: String
    var description: String
    var summary: String
    var author: String

    var image: String {
        "https://raw.githubusercontent.com/cilippofilia/drinko-learn-pics/main/\(id).jpg"
    }

#if DEBUG
    static let example = Book(id: "liquid-intelligence",
                              title: "Liquid Intelligence",
                              description: "Description of the book",
                              summary: "\"Liquid Intelligence\" by Dave Arnold is a captivating exploration of cocktail science and mixology. Arnold reveals the secrets behind exceptional drinks, incorporating physics and chemistry principles into his innovative recipes and techniques. This book is a must-read for aspiring mixologists, offering a unique perspective on the art of crafting extraordinary libations.",
                              author: "Example Author")
#endif
}
