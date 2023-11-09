//
//  Syrup.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 08/11/2023.
//

import Foundation

struct Syrup: Codable, Equatable, Identifiable {
    let id: String
    var title: String
    var description: String
    var body: String
    var image: String {
        "https://raw.githubusercontent.com/cilippofilia/drinko-learn-pics/main/\(id).jpg"
    }
    
#if DEBUG
    static let example = Syrup(id: "simple-syrup",
                               title: "Simple Syrup",
                               description: "This is an example of simple syrup",
                               body: "Dont worry, you will be fine.")
#endif
}
