//
//  CabinetView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 23/08/2023.
//

import SwiftUI

struct CabinetView: View {
    static let cabinetViewTag: String? = "Cabinet"

    @ObservedObject var favoriteProducts = FavoriteProduct()

    @StateObject var viewModel: ViewModel
    @State private var showingSortOrder = false

    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var familyList: some View {
        List {
            ForEach(viewModel.families) { family in
                Section(header: FamilyHeaderView(family: family)) {
                    ForEach(family.familyItems(using: viewModel.sortOrder)) { item in
                        ItemRowView(family: family, item: item)
                            .contextMenu {
                                Button(action: {
                                    if favoriteProducts.contains(item) {
                                        favoriteProducts.remove(item)
                                    } else {
                                        favoriteProducts.add(item)
                                        UINotificationFeedbackGenerator()
                                            .notificationOccurred(.success)
                                    }
                                }) {
                                    Image(systemName: "cart")
                                    Text(favoriteProducts.contains(item) ? "Remove from Cart" : "Add to Cart")
                                }
                            }
                    }
                    .onDelete { offsets in
                        viewModel.delete(offsets, from: family)
                    }

                    Button {
                        withAnimation {
                            viewModel.addItem(to: family)
                        }
                    } label: {
                        Label("Add New Product", systemImage: "plus")
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }

    var addFamilyToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                withAnimation {
                    viewModel.addFamily()
                }
            } label: {
                if UIAccessibility.isVoiceOverRunning {
                    Text("Add Family")
                } else {
                    Label("Add Family", systemImage: "plus")
                }
            }
        }
    }

    var sortOrderToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                showingSortOrder.toggle()
            } label: {
                Label("Sort", systemImage: "arrow.up.arrow.down")
            }
        }
    }

    var body: some View {
        Group {
            if viewModel.families.isEmpty {
                Text("Start adding categories and products\nby pressing the + above.")
                    .italic()
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                familyList
            }
        }
        .navigationTitle("Cabinet")
        .toolbar {
            addFamilyToolbarItem
            sortOrderToolbarItem
        }
        .actionSheet(isPresented: $showingSortOrder) {
            ActionSheet(title: Text("Sort products"),
                        message: nil,
                        buttons: [
                            .default(Text("Optimized")) { viewModel.sortOrder = .optimized },
                            .default(Text("Creation Date")) { viewModel.sortOrder = .creationDate },
                            .default(Text("Name")) { viewModel.sortOrder = .title },
                            .cancel()
                        ])
        }
        .environmentObject(favoriteProducts)
    }
}

#if DEBUG
struct CabinetView_Previews: PreviewProvider {
    let dataController = DataController()
    static var previews: some View {
        NavigationView {
            CabinetView(dataController: DataController())
        }
    }
}
#endif
