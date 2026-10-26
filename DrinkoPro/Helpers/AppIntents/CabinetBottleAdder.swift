import Foundation
import SwiftData

/// Adds a bottle to a Cabinet category and saves.
enum CabinetBottleAdder {
    @MainActor
    @discardableResult
    static func add(_ name: String, to category: Category, in context: ModelContext) throws -> Item {
        let item = Item(name: name)
        item.category = category
        if category.products == nil {
            category.products = [item]
        } else {
            category.products?.append(item)
        }
        try context.save()
        return item
    }
}
