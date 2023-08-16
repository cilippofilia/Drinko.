//
//  User.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 16/08/2023.
//

import Foundation

struct User: Identifiable, Equatable, Codable {
    var id: String
    var name: String
}

extension User {
    static let testUser = User(id: "", name: "John Wick")
}
