//
//  Spirit.swift
//  Drinko
//
//  Created by Filippo Cilia on 02/05/2023.
//

import SwiftUI

struct Spirit: Codable, Equatable, Identifiable {
    let id: String
    var title: String
    var text: String

    var image: String {
        id
    }

#if DEBUG
    static let example = Spirit(id: "vodka",
                                title: "Vodka",
                                text: "Vodka can be made from literally anything.")
#endif
}
