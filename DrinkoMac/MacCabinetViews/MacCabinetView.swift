//
//  MacCabinetView.swift
//  DrinkoMac
//
//  Created by Filippo Cilia on 19/01/2026.
//

import SwiftData
import SwiftUI

struct MacCabinetView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var path = NavigationPath()
    @State private var showAddCategorySheet: Bool = false

    @Query(sort: [
        SortDescriptor(\Category.name),
        SortDescriptor(\Category.creationDate)
    ]) var categories: [Category]

    var toolbarPlacement: ToolbarItemPlacement {
        #if os(iOS)
        .topBarTrailing
        #else
        .automatic
        #endif
    }

    var body: some View {
        NavigationStack(path: $path) {
            if categories.isEmpty {
                unavailableView
            } else {
                categoriesList
                    .navigationTitle("Cabinet")
            }
        }
        .navigationDestination(for: Category.self) { category in
            EditCategoryView(category: category, navigationPath: $path)
        }
    }
}

extension MacCabinetView {
    var unavailableView: some View {
        ContentUnavailableView(label: {
            Label("Empty Cabinet", systemImage: "cabinet.fill")
        }, description: {
            Text("To start, press 'Add a category' below or the + button at the top of the view.")
        }, actions: {
            Button("Add a category") {
                showAddCategorySheet.toggle()
            }
        })
        .frame(width: screenWidth)
        .navigationTitle("Cabinet")
        .toolbar {
            ToolbarItem(placement: toolbarPlacement) {
                Button(action: {
                    showAddCategorySheet.toggle()
                }) {
                    Label("Add category", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddCategorySheet) {
            AddCategoryView()
        }
    }

    var categoriesList: some View {
        List {
            ForEach(categories) { category in
                HStack {
                    Text(category.name)
                    Spacer()
                    Button {
                        path.append(category)
                    } label: {
                        Label("Edit", systemImage: "square.and.pencil")
                            .labelStyle(.iconOnly)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: toolbarPlacement) {
                Button {
                    showAddCategorySheet.toggle()
                } label: {
                    Label("Add category", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddCategorySheet) {
            AddCategoryView()
                .presentationDetents([.medium, .large])
        }
    }
}

#Preview {
    MacCabinetView()
}
