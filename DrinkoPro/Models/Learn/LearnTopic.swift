//
//  LearnTopic.swift
//  DrinkoPro
//

import Foundation

/// One Learn topic. `id` is also the name of the bundled JSON file holding its lessons.
struct LearnTopic: Identifiable, Hashable {
    let id: String
    let title: String

    /// Every topic, in display order. Add a topic by adding an entry here and a `<id>.json` file.
    static let all: [LearnTopic] = [
        LearnTopic(id: "basic-lessons", title: String(localized: "Basic Lessons")),
        LearnTopic(id: "bar-preps", title: String(localized: "Bar Preps")),
        LearnTopic(id: "basic-spirits", title: String(localized: "Basic Spirits")),
        LearnTopic(id: "advanced-spirits", title: String(localized: "Advanced Spirits")),
        LearnTopic(id: "liqueurs", title: String(localized: "Liqueurs")),
        LearnTopic(id: "advanced-lessons", title: String(localized: "Advanced Lessons")),
        LearnTopic(id: "syrups", title: String(localized: "Syrups"))
    ]
}
