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

    var body: some View {
        List {
            // MARK: ALL LESSONS
            ForEach(viewModel.topics, id: \.self) { topic in
                Section {
                    if !isCollapsed(for: topic) {
                        ForEach(viewModel.getLessons(for: topic)) { lesson in
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
                    ForEach(viewModel.books) { book in
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
        .navigationTitle("Learn")
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
