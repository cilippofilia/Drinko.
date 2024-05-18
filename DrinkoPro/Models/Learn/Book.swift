//
//  Book.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 28/06/2023.
//

import Foundation

struct Book: Codable, Equatable, Identifiable, Hashable {
    let id: String
    var title: String
    var description: String
    var summary: String
    var author: String

    var image: String {
        "https://raw.githubusercontent.com/cilippofilia/drinko-learn-pics/main/\(id).jpg"
    }
}
