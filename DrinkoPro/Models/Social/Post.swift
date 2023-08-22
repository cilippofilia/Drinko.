//
//  Post.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 12/08/2023.
//

import Foundation

struct Post: Identifiable, Equatable, Codable {
    var title: String
    var content: String
    var author: User
    var imageURL: URL?
    var isFavorite = false
    var timestamp = Date()
    var id = UUID()

    func contains(_ string: String) -> Bool {
        let properties = [title, content, author.name].map { $0.lowercased() }
        let query = string.lowercased()

        let matches = properties.filter { $0.contains(query) }
        return !matches.isEmpty
    }
}

extension Post {
    enum CodingKeys: CodingKey {
        case title, content, author, imageURL, timestamp, id
    }
}

extension Post {
    static let testPost = Post(title: "Lorem ipsum",
                               content: "1- Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.\n2- Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.\n3- Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                               author: User.testUser)
}
