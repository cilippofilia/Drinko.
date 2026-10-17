//
//  LearnLibrary.swift
//  DrinkoPro
//

import SwiftUI

struct LearnLibrary: View {
    @Environment(LessonsViewModel.self) private var viewModel
    @Environment(RecentsStore.self) private var recentsStore

    @AppStorage(LibraryLayout.learnStorageKey) private var layout: LibraryLayout = .initial()
    @AppStorage(CollapsedSections.learnStorageKey) private var collapsedSections = CollapsedSections()
    @State private var searchText = ""

    /// When set, the page shows only this library section and hides the recents deck.
    let sectionID: String?
    let selection: LearnView.Selection?
    let onSelect: @MainActor (LearnView.Selection) -> Void

    private var trimmedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isSearching: Bool {
        !trimmedSearchText.isEmpty
    }

    private var title: String {
        sectionID.flatMap(LessonsViewModel.sectionTitle(for:)) ?? String(localized: "Learn")
    }

    private var layoutTogglePlacement: ToolbarItemPlacement {
        #if os(iOS)
        return .topBarLeading
        #else
        return .automatic
        #endif
    }

    var body: some View {
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
                    title: title,
                    recentsTitle: String(localized: "Last Read"),
                    // Lesson photos fill their cards and would hide the hero's huge type.
                    recentsTitleStyle: .caption,
                    recents: sectionID == nil ? viewModel.recentItems(from: recentsStore.ids(in: .learn)) : [],
                    sections: sections,
                    selection: selection,
                    isSearching: isSearching,
                    collapsedSections: $collapsedSections,
                    layout: layout,
                    showsSectionHeaders: sectionID == nil,
                    onSelect: { onSelect($0) },
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
}
