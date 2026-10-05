//
//  LearnView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 22/04/2023.
//

import SwiftUI

struct LearnView: View {
    static let learnTag: String? = "Learn"

    @Environment(LessonsViewModel.self) private var viewModel
    @Environment(RecentsStore.self) private var recentsStore

    @State private var searchText = ""
    @State private var selection: Selection?
    @State private var preferredCompactColumn: NavigationSplitViewColumn = .sidebar

    @AppStorage(LibraryLayout.learnStorageKey) private var layout: LibraryLayout = .initial()
    @AppStorage("learnCollapsedSections") private var collapsedSections = CollapsedSections()

    private var trimmedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isSearching: Bool {
        !trimmedSearchText.isEmpty
    }

    private var layoutTogglePlacement: ToolbarItemPlacement {
        #if os(iOS)
        return .topBarLeading
        #else
        return .automatic
        #endif
    }

    var body: some View {
        NavigationSplitView(preferredCompactColumn: $preferredCompactColumn) {
            Group {
                let sections = viewModel.librarySections(matching: searchText)

                if isSearching && sections.isEmpty {
                    ContentUnavailableView(
                        label: {
                            Label("\"\(trimmedSearchText)\" not found", systemImage: "exclamationmark.magnifyingglass")
                        },
                        description: {
                            Text("No lessons or books match \"\(trimmedSearchText)\". Try a different search term or browse all topics.")
                        },
                        actions: {
                            Button("Clear Search", systemImage: "xmark.circle") {
                                searchText = ""
                            }
                            .buttonStyle(.bordered)
                        }
                    )
                } else {
                    LibraryView(
                        recentsTitle: String(localized: "Last Read"),
                        recents: viewModel.recentItems(from: recentsStore.ids(in: .learn)),
                        sections: sections,
                        selection: selection,
                        isSearching: isSearching,
                        collapsedSections: $collapsedSections,
                        layout: layout,
                        onSelect: select,
                        cardModel: viewModel.cardModel(for:),
                        contextMenu: { _ in EmptyView() }
                    )
                }
            }
            .navigationTitle("Learn")
            .searchable(text: $searchText, placement: .automatic, prompt: "Search lessons and books")
            .toolbar {
                ToolbarItem(placement: layoutTogglePlacement) {
                    LibraryLayoutToggle(layout: $layout)
                }
            }
            #if os(iOS) || os(macOS)
            .safeAreaInset(edge: .bottom) {
                CrossPromoBannerView()
            }
            #endif
        } detail: {
            if let selection {
                LearnDetailView(selection: selection)
                    // Recreate the detail so per-page state (e.g. calculator inputs) resets on a new selection.
                    .id(selection)
            } else {
                ContentUnavailableView(
                    "Select a Topic",
                    systemImage: "books.vertical",
                    description: Text("Choose a lesson, calculator or book to start learning.")
                )
            }
        }
    }

    /// Opens `item` in the detail column, pushing it on compact widths, and records it as recent.
    private func select(_ item: Selection) {
        selection = item
        preferredCompactColumn = .detail
        recentsStore.record(item.id, in: .learn)
    }
}

#if DEBUG
#Preview {
    LearnView()
        .drinkoPreviewEnvironment()
}
#endif
