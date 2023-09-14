//
//  CabinetViewModel.swift
//  Drinko
//
//  Created by Filippo Cilia on 25/04/2021.
//

import CoreData
import SwiftUI

extension CabinetView {
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        let dataController: DataController
//        let maxFamilies = 3
//        let maxItems = 9
        var sortOrder = Item.SortOrder.optimized

        private let familiesController: NSFetchedResultsController<Family>
        @Published var families = [Family]()
        @Published var showingUnlockView = false

        init(dataController: DataController) {
            self.dataController = dataController

            let request: NSFetchRequest<Family> = Family.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Family.creationDate, ascending: false)]

            familiesController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: dataController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )

            super.init()
            familiesController.delegate = self

            do {
                try familiesController.performFetch()
                families = familiesController.fetchedObjects ?? []
            } catch {
                print("Failed to fetch our categories!")
            }
        }

        func addFamily() {
//            let canAddCategories = dataController.plusVersionUnlocked || dataController.count(for: Family.fetchRequest()) < maxFamilies
//
//            if canAddCategories {
            let family = Family(context: dataController.container.viewContext)
            family.creationDate = Date()
            dataController.save()
//            } else {
//                showingUnlockView.toggle()
//            }
        }

        func addItem(to family: Family) {
//            let canAddItem = dataController.plusVersionUnlocked || dataController.count(for: Item.fetchRequest()) < maxItems
//
//            if canAddItem {
            let item = Item(context: dataController.container.viewContext)
            item.family = family
            item.creationDate = Date()
            dataController.save()
//            } else {
//                showingUnlockView.toggle()
//            }
        }

        func delete(_ offsets: IndexSet, from family: Family) {
            let allItems = family.familyItems(using: sortOrder)

            for offset in offsets {
                let item = allItems[offset]
                dataController.delete(item)
            }

            dataController.save()
        }

        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            if let newFamily = controller.fetchedObjects as? [Family] {
                families = newFamily
            }
        }
    }
}
