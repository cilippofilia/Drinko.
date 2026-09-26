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
    @State private var searchText = ""
    @State private var selection: Selection?

    @AppStorage("basicLessonsCollapsed") private var basicLessonsCollapsed = false
    @AppStorage("barPrepsCollapsed") private var barPrepsCollapsed = false
    @AppStorage("basicSpiritsCollapsed") private var basicSpiritsCollapsed = false
    @AppStorage("advancedSpiritsCollapsed") private var advancedSpiritsCollapsed = false
    @AppStorage("liqueursCollapsed") private var liqueursCollapsed = false
    @AppStorage("syrupsCollapsed") private var syrupsCollapsed = false
    @AppStorage("advancedLessonsCollapsed") private var advancedLessonsCollapsed = false
    @AppStorage("calculatorsCollapsed") private var isCalculatorsCollapsed = false
    @AppStorage("booksCollapsed") private var isBooksCollapsed = false
    
    private func isCollapsed(for topic: String) -> Bool {
        switch topic {
        case "basic-lessons": return basicLessonsCollapsed
        case "bar-preps": return barPrepsCollapsed
        case "basic-spirits": return basicSpiritsCollapsed
        case "advanced-spirits": return advancedSpiritsCollapsed
        case "liqueurs": return liqueursCollapsed
        case "syrups": return syrupsCollapsed
        case "advanced-lessons": return advancedLessonsCollapsed
        default: return false
        }
    }
    
    private func setCollapsed(for topic: String, value: Bool) {
        switch topic {
        case "basic-lessons": basicLessonsCollapsed = value
        case "bar-preps": barPrepsCollapsed = value
        case "basic-spirits": basicSpiritsCollapsed = value
        case "advanced-spirits": advancedSpiritsCollapsed = value
        case "liqueurs": liqueursCollapsed = value
        case "syrups": syrupsCollapsed = value
        case "advanced-lessons": advancedLessonsCollapsed = value
        default: break
        }
    }
    
    private var trimmedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isSearching: Bool {
        !trimmedSearchText.isEmpty
    }

    private func filteredLessons(for topic: String) -> [Lesson] {
        viewModel.filteredLessons(for: topic, matching: searchText)
    }

    private var filteredBooks: [Book] {
        viewModel.filteredBooks(matching: searchText)
    }

    private var hasSearchResults: Bool {
        viewModel.hasResults(matching: searchText)
    }

    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            if let selection {
                detailView(for: selection)
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

    @ViewBuilder
    private func detailView(for selection: Selection) -> some View {
        switch selection {
        case .lesson(let lesson):
            LessonDetailView(lesson: lesson)
        case .book(let book):
            BookDetailView(book: book)
        case .abvCalculator:
            ABVCalculator()
        case .superjuice(let juiceType):
            SuperJuiceView(typeOfJuice: juiceType)
        }
    }

    private var sidebar: some View {
        Group {
            if isSearching && !hasSearchResults {
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
                List(selection: $selection) {
                    if isSearching {
                        // MARK: SEARCH RESULTS
                        ForEach(viewModel.topics, id: \.self) { topic in
                            let lessons = filteredLessons(for: topic)
                            if !lessons.isEmpty {
                                Section(topic.replacing("-", with: " ").capitalizingFirstLetter()) {
                                    ForEach(lessons) { lesson in
                                        LessonRowView(lesson: lesson)
                                            .tag(Selection.lesson(lesson))
                                    }
                                }
                            }
                        }
                        let books = filteredBooks
                        if !books.isEmpty {
                            Section("Books") {
                                ForEach(books) { book in
                                    BookRowView(book: book)
                                        .tag(Selection.book(book))
                                }
                            }
                        }
                    } else {
                        // MARK: ALL LESSONS
                        ForEach(viewModel.topics, id: \.self) { topic in
                            Section {
                                if !isCollapsed(for: topic) {
                                    ForEach(filteredLessons(for: topic)) { lesson in
                                        LessonRowView(lesson: lesson)
                                            .tag(Selection.lesson(lesson))
                                    }
                                }
                            } header: {
                                LearnHeaderView(
                                    isCollapsed: Binding(
                                        get: { isCollapsed(for: topic) },
                                        set: { setCollapsed(for: topic, value: $0) }
                                    ),
                                    text: topic.replacing("-", with: " ").capitalizingFirstLetter()
                                )
                            }
                        }
                        // MARK: CALCULATORS
                        Section {
                            if !isCalculatorsCollapsed {
                                ABVRowView()
                                    .tag(Selection.abvCalculator)
                                SuperjuiceRowView(juiceType: "lime")
                                    .tag(Selection.superjuice("lime"))
                                SuperjuiceRowView(juiceType: "lemon")
                                    .tag(Selection.superjuice("lemon"))
                            }
                        } header: {
                            LearnHeaderView(
                                isCollapsed: $isCalculatorsCollapsed,
                                text: "Calculators"
                            )
                        }
                        // MARK: BOOKS
                        Section {
                            if !isBooksCollapsed {
                                ForEach(filteredBooks) { book in
                                    BookRowView(book: book)
                                        .tag(Selection.book(book))
                                }
                            }
                        } header: {
                            LearnHeaderView(
                                isCollapsed: $isBooksCollapsed,
                                text: "Books"
                            )
                        }
                    }
                }
            }
        }
        .navigationTitle("Learn")
        .searchable(text: $searchText, placement: .automatic, prompt: "Search lessons and books")
        #if os(iOS)
        .listSectionSpacing(.compact)
        #endif
        #if os(iOS) || os(macOS)
        .safeAreaInset(edge: .bottom) {
            CrossPromoBannerView()
        }
        #endif
    }
}

#if DEBUG
#Preview {
    LearnView()
        .drinkoPreviewEnvironment()
}
#endif
