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
        let lessons = viewModel.getLessons(for: topic)
        guard isSearching else { return lessons }
        return lessons.filter { lesson in
            lesson.title.localizedCaseInsensitiveContains(trimmedSearchText) ||
            lesson.description.localizedCaseInsensitiveContains(trimmedSearchText)
        }
    }
    
    private var filteredBooks: [Book] {
        let books = viewModel.books
        guard isSearching else { return books }
        return books.filter { book in
            book.title.localizedCaseInsensitiveContains(trimmedSearchText) ||
            book.description.localizedCaseInsensitiveContains(trimmedSearchText) ||
            book.author.localizedCaseInsensitiveContains(trimmedSearchText)
        }
    }
    
    private var hasSearchResults: Bool {
        guard isSearching else { return true }
        if !filteredBooks.isEmpty {
            return true
        }
        for topic in viewModel.topics {
            if !filteredLessons(for: topic).isEmpty {
                return true
            }
        }
        return false
    }

    var body: some View {
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
                List {
                    if isSearching {
                        // MARK: SEARCH RESULTS
                        ForEach(viewModel.topics, id: \.self) { topic in
                            let lessons = filteredLessons(for: topic)
                            if !lessons.isEmpty {
                                Section(topic.replacing("-", with: " ").capitalizingFirstLetter()) {
                                    ForEach(lessons) { lesson in
                                        NavigationLink(value: lesson) {
                                            LessonRowView(lesson: lesson)
                                        }
                                    }
                                }
                            }
                        }
                        let books = filteredBooks
                        if !books.isEmpty {
                            Section("Books") {
                                ForEach(books) { book in
                                    NavigationLink(value: book) {
                                        BookRowView(book: book)
                                    }
                                }
                            }
                        }
                    } else {
                        // MARK: ALL LESSONS
                        ForEach(viewModel.topics, id: \.self) { topic in
                            Section {
                                if !isCollapsed(for: topic) {
                                    ForEach(filteredLessons(for: topic)) { lesson in
                                        NavigationLink(value: lesson) {
                                            LessonRowView(lesson: lesson)
                                        }
                                    }
                                }
                            } header: {
                                LearnHeaderView(
                                    text: topic.replacing("-", with: " ").capitalizingFirstLetter(),
                                    isCollapsed: Binding(
                                        get: { isCollapsed(for: topic) },
                                        set: { setCollapsed(for: topic, value: $0) }
                                    )
                                )
                            }
                        }
                        // MARK: CALCULATORS
                        Section {
                            if !isCalculatorsCollapsed {
                                ABVRowView()
                                SuperjuiceRowView(juiceType: "lime")
                                SuperjuiceRowView(juiceType: "lemon")
                            }
                        } header: {
                            LearnHeaderView(
                                text: "Calculators",
                                isCollapsed: $isCalculatorsCollapsed)
                        }
                        // MARK: BOOKS
                        Section {
                            if !isBooksCollapsed {
                                ForEach(filteredBooks) { book in
                                    NavigationLink(value: book) {
                                        BookRowView(book: book)
                                    }
                                }
                            }
                        } header: {
                            LearnHeaderView(
                                text: "Books",
                                isCollapsed: $isBooksCollapsed)
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
        .navigationDestination(for: Lesson.self) { lesson in
            LessonDetailView(lesson: lesson)
        }
        .navigationDestination(for: Book.self) { book in
            BookDetailView(book: book)
        }
    }
}

#if DEBUG
#Preview {
    LearnView()
}
#endif
