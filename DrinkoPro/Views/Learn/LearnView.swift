//
//  LearnView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 22/04/2023.
//

import SwiftUI

struct LearnView: View {
    @Environment(RecentsStore.self) private var recentsStore

    /// When set, the page shows only this library section and hides the recents deck.
    private let sectionID: String?

    #if os(iOS)
    @State private var path: [Selection] = []
    #else
    @State private var selection: Selection?
    @State private var preferredCompactColumn: NavigationSplitViewColumn = .sidebar
    #endif

    init(sectionID: String? = nil) {
        self.sectionID = sectionID
    }

    /// The item shown (iOS: the first pushed page; macOS: the detail column).
    private var currentSelection: Selection? {
        #if os(iOS)
        path.first
        #else
        selection
        #endif
    }

    private var navigation: LibraryNavigationBindings<Selection> {
        #if os(iOS)
        .init(path: $path)
        #else
        .init(selection: $selection, preferredCompactColumn: $preferredCompactColumn)
        #endif
    }

    var body: some View {
        LibraryNavigationContainer(
            navigation: navigation,
            library: {
                LearnLibrary(sectionID: sectionID, selection: currentSelection, onSelect: select)
            },
            detail: { LearnDetailView(selection: $0) },
            placeholder: {
                ContentUnavailableView(
                    "Select a Topic",
                    systemImage: "books.vertical",
                    description: Text("Choose a lesson or book to start learning.")
                )
            }
        )
        .task(id: currentSelection) {
                // Record only once the selection settles; a new selection cancels this.
                guard let currentSelection else { return }
                try? await Task.sleep(for: RecentsStore.recordDelay)
                guard !Task.isCancelled else { return }
                recentsStore.record(currentSelection.id, in: .learn)
            }
    }

    /// Recorded as recent once the selection settles (see the `.task(id:)` in `body`).
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
