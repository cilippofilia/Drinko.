//
//  UserCocktailViewModel.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 20/01/2024.
//

import CoreData
import SwiftUI

extension UserCreationsView {
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        let dataController: DataController

        private let userCocktailsController: NSFetchedResultsController<UserCocktail>
        @Published var userCocktails = [UserCocktail]()

        init(dataController: DataController) {
            self.dataController = dataController

            let request: NSFetchRequest<UserCocktail> = UserCocktail.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \UserCocktail.creationDate, ascending: false)]

            userCocktailsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: dataController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )

            super.init()
            userCocktailsController.delegate = self

            do {
                try userCocktailsController.performFetch()
                userCocktails = userCocktailsController.fetchedObjects ?? []
            } catch {
                print("Failed to fetch our categories!")
            }
        }

        func addUserCocktail() {
            let userCocktail = UserCocktail(context: dataController.container.viewContext)
            userCocktail.creationDate = Date()
            dataController.save()
        }

        func addIngredient(to userCocktail: UserCocktail) {
            let userIngredient = UserIngredient(context: dataController.container.viewContext)
            userIngredient.userCocktail = userCocktail
            userIngredient.creationDate = Date()
            dataController.save()
        }

        func delete(_ offsets: IndexSet, from userCocktail: UserCocktail) {
            let allIngredients = userCocktail.userCocktailIngredients

            for offset in offsets {
                let userIngredient = allIngredients[offset]
                dataController.delete(userIngredient)
            }

            dataController.save()
        }

        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            if let newUserCocktail = controller.fetchedObjects as? [UserCocktail] {
                userCocktails = newUserCocktail
            }
        }
    }
}
