//
//  Family-CDHelpers.swift
//  Drinko
//
//  Created by Filippo Cilia on 04/02/2021.
//

import Foundation

extension Family {
    static let colors = [
        "Pink",
        "Purple",
        "Red",
        "Orange",
        "Gold",
        "Green",
        "Teal",
        "Drinko Blue",
        "Dark Blue",
        "Midnight",
        "Dark Gray",
        "Gray"
    ]

    var familyName: String {
        name ?? "Category Name"
    }
    
    var familyDetail: String {
        detail ?? ""
    }
    
    var familyColor: String {
        color ?? "Drinko Blue"
    }
    
    var familyCreationDate: Date {
        creationDate ?? Date()
    }
    
    var familyItems: [Item] {
        items?.allObjects as? [Item] ?? []
    }

    var familyItemsDefaultSorted: [Item] {

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
        family.color = "Dark Gray"
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
            return familyItemsDefaultSorted
        }
    }

    func familyItems<Value: Comparable>(sortedBy keyPath: KeyPath<Item, Value>) -> [Item] {
        familyItems.sorted {
            $0[keyPath: keyPath] < $1[keyPath: keyPath]
        }
    }

}
