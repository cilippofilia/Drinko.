//
//  Family-CDHelpers.swift
//  Drinko
//
//  Created by Filippo Cilia on 05/05/2023.
//

import CoreData
import SwiftUI

extension Family {
    static let colors = [
        "Pink",
        "Purple",
        "Red",
        "Orange",
        "Gold",
        "Green",
        "Teal",
        "Light Blue",
        "Dark Blue",
        "Midnight",
        "Dark Gray",
        "Gray"
    ]

    var familyName: String {
        name ?? "Category name"
    }

    var familyDetail: String {
        detail ?? ""
    }

    var familyColor: String {
        color ?? "Blue"
    }

    var familyCreationDay: Date {
        creationDate ?? Date()
    }

    var familyItems: [Item] {
        items?.allObjects as? [Item] ?? []
    }

    var familyItemDefaultSorted: [Item] {
        familyItems.sorted { first, second in
            if first.tried == false {
                if second.tried == true {
                    return true
                }
            } else if first.tried == true {
                if second.tried == false {
                    return false
                }
            }

            if first.rating > second.rating {
                return true
            } else if first.rating < second.rating {
                return false
            }

            return first.itemCreationDate < second.itemCreationDate
        }
    }

    static var example: Family {
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext

        let family = Family(context: viewContext)
        family.name = "Example item"
        family.detail = ""
        family.color = "Blue"
        family.creationDate = Date()

        return family
    }

    func familyItems(using sortOrder: Item.SortOrder) -> [Item] {
        switch sortOrder {
        case .title:
            return familyItems.sorted(by: \Item.itemName)

        case .creationDate:
            return familyItems.sorted(by: \Item.itemCreationDate)

        case .optimized:
            return familyItemDefaultSorted
        }
    }

    func familyItems<Value: Comparable>(sortedBy keyPath: KeyPath<Item, Value>) -> [Item] {
        familyItems.sorted {
            $0[keyPath: keyPath] < $1[keyPath: keyPath]
        }
    }
}
