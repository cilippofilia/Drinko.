//
//  LearnView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 22/04/2023.
//

import SwiftUI

struct LearnView: View {
    @Environment(LessonsViewModel.self) private var viewModel
    @Environment(RecentsStore.self) private var recentsStore

    /// When set, the page shows only this library section (an iPad sidebar row) and hides the
    /// recents deck. `nil` shows the whole library.
    private let sectionID: String?

    @State private var searchText = ""
    #if os(iOS)
    @State private var path: [Selection] = []
    #else
    @State private var selection: Selection?
    @State private var preferredCompactColumn: NavigationSplitViewColumn = .sidebar
    #endif

    @AppStorage(LibraryLayout.learnStorageKey) private var layout: LibraryLayout = .initial()
    @AppStorage("learnCollapsedSections") private var collapsedSections = CollapsedSections()

    init(sectionID: String? = nil) {
        self.sectionID = sectionID
    }

    private var trimmedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isSearching: Bool {
        !trimmedSearchText.isEmpty
    }

    private var title: String {
        sectionID.flatMap(LessonsViewModel.sectionTitle(for:)) ?? String(localized: "Learn")
    }

    /// The item shown (iOS: the first pushed page; macOS: the detail column).
    private var currentSelection: Selection? {
        #if os(iOS)
        path.first
        #else
        selection
        #endif
    }

    private var layoutTogglePlacement: ToolbarItemPlacement {
        #if os(iOS)
        return .topBarLeading
        #else
        return .automatic
        #endif
    }

    var body: some View {
        container
            .task(id: currentSelection) {
                // Record only once the selection settles; a new selection cancels this.
                guard let currentSelection else { return }
                try? await Task.sleep(for: RecentsStore.recordDelay)
                guard !Task.isCancelled else { return }
                recentsStore.record(currentSelection.id, in: .learn)
            }
    }

    @ViewBuilder
    private var container: some View {
        #if os(iOS)
        NavigationStack(path: $path) {
            library
                .navigationDestination(for: Selection.self) { item in
                    LearnDetailView(selection: item)
                }
        }
        #else
        NavigationSplitView(preferredCompactColumn: $preferredCompactColumn) {
            library
        } detail: {
            NavigationStack {
                if let selection {
                    LearnDetailView(selection: selection)
                } else {
                    ContentUnavailableView(
                        "Select a Topic",
                        systemImage: "books.vertical",
                        description: Text("Choose a lesson or book to start learning.")
                    )
                }
            }
            // Recreate the detail so per-page state resets on a new selection.
            .id(selection)
        }
        #endif
    }

    private var library: some View {
        Group {
            let sections = viewModel.librarySections(matching: searchText)
                .filter { sectionID == nil || $0.id == sectionID }

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
                    recents: sectionID == nil ? viewModel.recentItems(from: recentsStore.ids(in: .learn)) : [],
                    sections: sections,
                    selection: currentSelection,
                    isSearching: isSearching,
                    collapsedSections: $collapsedSections,
                    layout: layout,
                    showsSectionHeaders: sectionID == nil,
                    onSelect: select,
                    cardModel: viewModel.cardModel(for:),
                    contextMenu: { _ in EmptyView() }
                )
            }
        }
        .navigationTitle(title)
        .searchable(text: $searchText, placement: .automatic, prompt: "Search lessons and books")
        .toolbar {
            ToolbarItem(placement: layoutTogglePlacement) {
                LibraryLayoutToggle(layout: $layout)
            }
        }
        #if os(iOS) || os(macOS)
        .crossPromoBanner()
        #endif
    }

    /// Opens `item`: pushes it on iOS, shows it in the detail column on macOS. It's recorded
    /// as recent once the selection settles (see the `.task(id:)` in `body`).
    private func select(_ item: Selection) {
        #if os(iOS)
        path = [item]
        #else
        selection = item
        preferredCompactColumn = .detail
        #endif
    }
}

#if DEBUG
#Preview {
    LearnView()
        .drinkoPreviewEnvironment()
}
#endif
