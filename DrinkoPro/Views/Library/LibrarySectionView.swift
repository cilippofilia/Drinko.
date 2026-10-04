//
//  LibrarySectionView.swift
//  DrinkoPro
//

import SwiftUI

/// A collapsible section showing its items as a list or a grid.
struct LibrarySectionView<Item: Hashable, MenuContent: View>: View {
    @ScaledMetric private var gridMinimumWidth: CGFloat = 140

    let section: LibrarySection<Item>
    let layout: LibraryLayout
    let isCollapsed: Bool
    let isCollapsible: Bool
    let selection: Item?
    let onToggleCollapsed: () -> Void
    let onSelect: @MainActor (Item) -> Void
    let cardModel: @MainActor (Item) -> LibraryCardModel
    @ViewBuilder let contextMenu: @MainActor (Item) -> MenuContent

    var body: some View {
        VStack(alignment: .leading) {
            LibrarySectionHeader(
                title: section.title,
                isCollapsed: isCollapsed,
                isEnabled: isCollapsible,
                action: onToggleCollapsed
            )

            if !isCollapsed {
                switch layout {
                case .list:
                    LazyVStack(spacing: 0) {
                        ForEach(section.items, id: \.self) { item in
                            LibraryItemButton(isSelected: selection == item) {
                                onSelect(item)
                            } label: {
                                LibraryRowView(model: cardModel(item), isSelected: selection == item)
                            } contextMenu: {
                                contextMenu(item)
                            }

                            if item != section.items.last {
                                Divider()
                                    .padding(.leading)
                            }
                        }
                    }
                    .background(.background.secondary)
                    .clipShape(.rect(cornerRadius: libraryCardCornerRadius))
                case .grid:
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: gridMinimumWidth), alignment: .top)]) {
                        ForEach(section.items, id: \.self) { item in
                            LibraryItemButton(isSelected: selection == item) {
                                onSelect(item)
                            } label: {
                                LibraryCardView(model: cardModel(item), isSelected: selection == item)
                            } contextMenu: {
                                contextMenu(item)
                            }
                        }
                    }
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    ScrollView {
        LibrarySectionView(
            section: LibrarySection(id: "demo", title: "Demo", items: ["Negroni", "Daiquiri", "Martini"]),
            layout: .grid,
            isCollapsed: false,
            isCollapsible: true,
            selection: "Daiquiri",
            onToggleCollapsed: { },
            onSelect: { _ in },
            cardModel: { LibraryCardModel(title: $0, image: .symbol("wineglass"), imageContentMode: .fit) },
            contextMenu: { _ in EmptyView() }
        )
        .padding()
    }
}
#endif
