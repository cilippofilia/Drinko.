//
//  Spirit.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 02/05/2023.
//

import SwiftUI

struct Spirit: Codable, Equatable, Identifiable {
    let id: String
    var title: String
    var description: String
    var body: String

    var image: String {
        "https://raw.githubusercontent.com/cilippofilia//drinko-learn-pics/main/\(id).jpg"
    }

#if DEBUG
    static let example = Spirit(id: "vodka",
                                title: "Vodka",
                                description: "Vodka can be made from literally anything.",
                                body: "Testing how this will look.")
#endif
}
