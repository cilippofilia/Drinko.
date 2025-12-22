//
//  CabinetView.swift
//  DrinkoMac
//
//  Created by Filippo Cilia on 18/12/2025.
//

import SwiftData
import SwiftUI

struct CabinetView: View {
    static let cabinetTag: String? = "Cabinet"
    @Environment(\.modelContext) private var modelContext

    @State private var selection: Category?

    @Query(sort: [
        SortDescriptor(\Category.name),
        SortDescriptor(\Category.creationDate)
    ]) var categories: [Category]

    var body: some View {
        NavigationSplitView {
            if !categories.isEmpty {
                Text("sidebar")
            } else {
                noCategoriesView(title: "Category", description: "To start, press 'Add Category' below or the + button at the top of the view.")
            }
        } detail: {
            if let selection = selection {
                Text("details")
            } else {
                noCategoriesView(title: "Item", description: "To start, select a category from the side bar or from below or the + button at the top of the window.")
            }
        }
        .toolbar {
            ToolbarItem {
                Button(action: {

                }) {
                    Label("Add category", systemImage: "plus")
                }
            }
        }

    }

    func noCategoriesView(title: String, description: String) -> some View {
        ContentUnavailableView(label: {
            Label(title, systemImage: "cabinet.fill")
        }, description: {
            Text(description)
        }, actions: {
            Button("Add Category") {

            }
        })
    }
}

#Preview {
    CabinetView()
}
