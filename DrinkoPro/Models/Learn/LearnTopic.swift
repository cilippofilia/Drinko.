//
//  LearnTopic.swift
//  DrinkoPro
//

import Foundation

/// One Learn topic. `id` is also the name of the JSON file holding its lessons.
nonisolated struct LearnTopic: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    /// An SF Symbol name. May not exist on the running OS; see `LessonsViewModel.sidebarSymbol(for:)`.
    let symbol: String

    /// Shown when a topic's symbol isn't available on the running OS.
    nonisolated static let fallbackSymbol = "book"

    /// The topics shipped in the app, in display order, from the localized `topics.json`.
    /// Empty if the file is missing or malformed.
    nonisolated static var bundled: [LearnTopic] {
        guard let url = Bundle.main.url(forResource: "topics", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let topics = try? JSONDecoder().decode([LearnTopic].self, from: data) else {
            return []
        }
        return topics
    }
}
