//
//  CabinetView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 23/08/2023.
//

import SwiftUI
import TipKit

struct CabinetView: View {
    static let cabinetViewTag: String? = "Cabinet"
    
    @Environment(\.horizontalSizeClass) var sizeClass
    
    @ObservedObject var favoriteProducts = FavoriteProduct()

    @StateObject var viewModel: ViewModel
    @State private var showingSortOrder = false

    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // TipKit variable
    var favoriteItemTip = SwipeToCartTip()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.families.isEmpty {
                    /// This VStack can be replaced by ContentUnavailableView
                    /// available only from iOS17 onwards
                    VStack {
                        Image(systemName: "cabinet.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 44)
                        
                        Text("Start adding categories and products by pressing the + above.")
                    }
                    .italic()
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: sizeClass == .compact ? compactScreenWidth : regularScreenWidth)

                } else {
                    cabinetList
                }
            }
            .navigationTitle("Cabinet")
            .navigationSplitViewStyle(AutomaticNavigationSplitViewStyle())
            .toolbar {
                addFamilyToolbarItem
                sortOrderToolbarItem
            }
        }
    }
}

private extension CabinetView {
    var cabinetList: some View {
        List {
            ForEach(viewModel.families) { family in
                Section(header: FamilyHeaderView(family: family)) {
                    if #available(iOS 17.0, *) {
                        TipView(favoriteItemTip, arrowEdge: .bottom)
                    }
                    ForEach(family.familyItems(using: viewModel.sortOrder)) { item in
                        ItemRowView(family: family, item: item)
                            .swipeActions(edge: .leading) {
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
                            .tint(favoriteProducts.contains(item) ? .red : .blue)
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
        .task {
            if #available(iOS 17.0, *) {
                // Configure and load your tips at app launch.
                try? Tips.configure([
                    .displayFrequency(.immediate),
                    .datastoreLocation(.applicationDefault)
                ])
            }
        }
    }
}

private extension CabinetView {
    var addFamilyToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
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
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showingSortOrder.toggle()
            } label: {
                Label("Sort", systemImage: "arrow.up.arrow.down")
            }
            .confirmationDialog("Sort products",
                                isPresented: $showingSortOrder) {
                Button("Optimized") {
                    viewModel.sortOrder = .optimized
                }
                Button("Creation Date") {
                    viewModel.sortOrder = .creationDate
                }
                Button("Name") {
                    viewModel.sortOrder = .title
                }
            }
            .environmentObject(favoriteProducts)
        }
    }
}

#Preview {
    NavigationStack {
        CabinetView(dataController: DataController())
    }
}
