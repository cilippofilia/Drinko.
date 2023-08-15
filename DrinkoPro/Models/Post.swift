//
//  Post.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 12/08/2023.
//

import Foundation

struct Post: Identifiable, Codable, Equatable {
    var title: String
    var content: String
    var authorName: String
    var timestamp = Date()
    var id = UUID()

    func contains(_ string: String) -> Bool {
        let properties = [title, content, authorName].map { $0.lowercased() }
        let query = string.lowercased()

        let matches = properties.filter { $0.contains(query) }
        return !matches.isEmpty
    }
}

extension Post {
    static let testPost = Post(title: "Lorem ipsum",
                               content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                               authorName: "John Wick")
}
