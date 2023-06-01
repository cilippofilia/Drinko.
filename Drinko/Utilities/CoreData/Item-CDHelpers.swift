//
//  Item-CDHelpers.swift
//  Drinko
//
//  Created by Filippo Cilia on 05/05/2023.
//

import SwiftUI

extension Item {
    enum SortOrder {
        case optimized, title, creationDate
    }

    var itemName: String {
        name ?? "Insert product name"
    }

    var itemDetail: String {
        detail ?? ""
    }

    var itemABV: Double {
        abv
    }

    var itemCreationDate: Date {
        creationDate ?? Date()
    }

    static var example: Item {
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext

        let item = Item(context: viewContext)
        item.name = "Example product"
        item.detail = "Example detail"
        item.abv = 30.00
        item.rating = 3
        item.tried = Bool.random()
        item.creationDate = Date()

        return item
    }
}
