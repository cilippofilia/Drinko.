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
}

struct LessonContent: Codable, Equatable, Identifiable {
    var id: String { heading }
    let heading: String
    let content: String
}
