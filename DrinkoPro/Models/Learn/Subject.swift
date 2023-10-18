//
//  Subject.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 18/10/2023.
//

import Foundation

struct Subject: Codable, Equatable, Identifiable {
    let id: String
    var name: String
    var lessons: [Lesson]

#if DEBUG
    static let example = Subject(id: "example",
                                 name: "Example Subject",
                                 lessons: [Lesson.example, Lesson.example, Lesson.example])
#endif
}

