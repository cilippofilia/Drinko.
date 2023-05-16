//
//  History.swift
//  Drinko
//
//  Created by Filippo Cilia on 16/05/2023.
//

import SwiftUI

struct History: Codable, Equatable, Identifiable {
    let id: String
    let text: String

#if DEBUG
    static let example = History(id: "mai-tai",
                                 text: "The Mai Tai is one of the quintessential cocktails in Tiki culture. This tale began in 1944, according to Victor J. Bergeron, better known as Trader Vic. He tells the story of the day when he was serving two friends, Eastham and Carrie Guild from Tahiti, at his restaurant, \"Trader Vic\", in Oakland, California. After serving the drink to his friends, Carrie took a sip and exclaimed, \"Mai Tai-Roa Aé\", which means \"Out of this world - the best\".")
#endif
}

