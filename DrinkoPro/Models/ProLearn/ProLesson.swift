//
//  ProLesson.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 18/10/2023.
//

import Foundation

struct ProLesson: Identifiable, Decodable {
    let id: String
    var title: String
    var description: String
    var body: String

    var img: String { id }

    #if DEBUG
    static let sample = ProLesson(id: "test",
                                  title: "Test",
                                  description: "This is a test",
                                  body: "This is a very long test.")
    #endif
}
