//
//  LibrarySectionView.swift
//  DrinkoPro
//

import SwiftUI

/// A collapsible section showing its items as a list or a grid.
struct LibrarySectionView<Item: Identifiable & Hashable, MenuContent: View>: View {
    @ScaledMetric private var gridMinimumWidth: CGFloat = 140

    let section: LibrarySection<Item>
    let layout: LibraryLayout
    var showsHeader = true
    let isCollapsed: Bool
    let isCollapsible: Bool
    let selection: Item?
    let onToggleCollapsed: () -> Void
    let onSelect: @MainActor (Item) -> Void
    let cardModel: @MainActor (Item) -> LibraryCardModel
    @ViewBuilder let contextMenu: @MainActor (Item) -> MenuContent

    var body: some View {
        VStack(alignment: .leading) {
            if showsHeader {
                LibrarySectionHeader(
                    title: section.title,
                    isCollapsed: isCollapsed,
                    isEnabled: isCollapsible,
                    action: onToggleCollapsed
                )
            }

            if !isCollapsed {
                switch layout {
                case .list:
                    LazyVStack(spacing: 0) {
                        ForEach(section.items) { item in
                            VStack(spacing: 0) {
                                LibraryItemButton(isSelected: selection?.id == item.id, layout: .list) {
                                    onSelect(item)
                                } label: {
                                    LibraryRowView(model: cardModel(item))
                                } contextMenu: {
                                    contextMenu(item)
                                }
                                .buttonStyle(.plain)

                                Divider()
                                    .padding(.leading)
                                    .opacity(item.id == section.items.last?.id ? 0 : 1)
                                    .accessibilityHidden(true)
                            }
                        }
                    }
                    .background(.background.secondary)
                    .clipShape(.rect(cornerRadius: libraryCardCornerRadius))
                case .grid:
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: gridMinimumWidth), alignment: .top)]) {
                        ForEach(section.items) { item in
                            LibraryItemButton(isSelected: selection?.id == item.id, layout: .grid) {
                                onSelect(item)
                            } label: {
                                LibraryCardView(model: cardModel(item))
                            } contextMenu: {
                                contextMenu(item)
                            }
                            .buttonStyle(.libraryCard)
                        }
                    }
                }
            }
        }
    }
}

#if DEBUG
/// A minimal `Identifiable` item for previews.
private struct PreviewItem: Identifiable, Hashable {
    let id: String
}

#Preview {
    let items = ["Negroni", "Daiquiri", "Martini"].map(PreviewItem.init(id:))
    ScrollView {
        LibrarySectionView(
            section: LibrarySection(id: "demo", title: "Demo", items: items),
            layout: .grid,
            isCollapsed: false,
            isCollapsible: true,
            selection: items[1],
            onToggleCollapsed: { },
            onSelect: { _ in },
            cardModel: { LibraryCardModel(title: $0.id, image: .symbol("wineglass"), imageContentMode: .fit) },
            contextMenu: { _ in EmptyView() }
        )
        .padding()
    }
}
#endif
