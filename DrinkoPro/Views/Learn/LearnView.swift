//
//  LearnView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 22/04/2023.
//

import SwiftUI

struct LearnView: View {
    static let learnTag: String? = "Learn"
    @State private var viewModel = LessonsViewModel()

    @State private var collapsedStates: [String: Bool] = UserDefaults.standard.dictionary(forKey: "mobileCollapsedStates") as? [String: Bool] ?? [
        "basic-lessons": false,
        "bar-preps": false,
        "basic-spirits": false,
        "advanced-spirits": false,
        "liqueurs": false,
        "syrups": false,
        "advanced-techniques": false,
    ] {
        didSet {
            UserDefaults.standard.set(collapsedStates, forKey: "collapsedStates")
        }
    }
    @State private var isCalculatorsCollapsed = false
    @State private var isBooksCollapsed = false

    var body: some View {
        NavigationStack {
            List {
                // MARK: ALL LESSONS
                ForEach(viewModel.topics, id: \.self) { topic in
                    Section {
                        if !(collapsedStates[topic] ?? false) {
                            ForEach(viewModel.getLessons(for: topic)) { lesson in
                                NavigationLink(value: lesson) {
                                    LessonRowView(lesson: lesson)
                                }
                            }
                        }
                    } header: {
                        LearnHeaderView(
                            text: topic.replacingOccurrences(of: "-", with: " ").capitalizingFirstLetter(),
                            isCollapsed: Binding(
                                get: { collapsedStates[topic] ?? false },
                                set: { collapsedStates[topic] = $0 }
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
            .navigationDestination(for: Lesson.self) { lesson in
                LessonDetailView(lesson: lesson)
            }
            .navigationDestination(for: Book.self) { book in
                BookDetailView(book: book)
            }
            .listSectionSpacing(.compact)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#if DEBUG
#Preview {
    LearnView()
}
#endif
