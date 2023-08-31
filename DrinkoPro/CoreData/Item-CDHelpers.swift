//
//  Item-CDHelpers.swift
//  Drinko
//
//  Created by Filippo Cilia on 04/02/2021.
//

import SwiftUI

extension Item {
    enum SortOrder {
        case optimized, title, creationDate
    }

    var itemName: String {
        name ?? "Insert Product Name"
    }
    
    var itemDetail: String {
        detail ?? ""
    }
    
    var itemAbv: String {
        abv ?? "-"
    }
    
    var itemMadeIn: String {
        madeIn ?? ""
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
        item.abv = "30"
        item.rating = 3
        item.tried = Bool.random()
        item.creationDate = Date()
        item.madeIn = "Mars"
        
        return item
    }
}
