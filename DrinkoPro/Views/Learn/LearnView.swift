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

    @State private var isBasicCollapsed = false
    @State private var isBarPrepsCollapsed = false
    @State private var isBasicSpiritsCollapsed = false
    @State private var isAdvSpiritsCollapsed = false
    @State private var isLiqueursCollapsed = false
    @State private var isSyrupsCollapsed = false
    @State private var isAdvTechniquesCollapsed = false
    @State private var isCalculatorsCollapsed = false
    @State private var isBooksCollapsed = false

    var body: some View {
        NavigationStack {
            List {
                // MARK: BASIC LESSONS
                Section {
                    if isBasicCollapsed {
                        NavigationLink(value: viewModel.basicLessons[0]) {
                            LessonRowView(lesson: viewModel.basicLessons[0])
                        }
                    } else {
                        ForEach(viewModel.basicLessons, id: \.id) { lesson in
                            NavigationLink(value: lesson) {
                                LessonRowView(lesson: lesson)
                            }
                        }
                    }
                } header: {
                    LearnHeaderView(
                        text: "Basic",
                        isCollapsed: $isBasicCollapsed)
                }

                // MARK: BAR PREPS
                Section {
                    if isBarPrepsCollapsed {
                        NavigationLink(value: viewModel.barPreps[0]) {
                            LessonRowView(lesson: viewModel.barPreps[0])
                        }
                    } else {
                        ForEach(viewModel.barPreps, id: \.id) { lesson in
                            NavigationLink(value: lesson) {
                                LessonRowView(lesson: lesson)
                            }
                        }
                    }
                } header: {
                    LearnHeaderView(
                        text: "Bar Preps",
                        isCollapsed: $isBarPrepsCollapsed)
                }

                // MARK: BASIC SPIRITS
                Section {
                    if isBasicSpiritsCollapsed {
                        NavigationLink(value: viewModel.basicSpirits[0]) {
                            LessonRowView(lesson: viewModel.basicSpirits[0])
                        }
                    } else {
                        ForEach(viewModel.basicSpirits) { spirit in
                            NavigationLink(value: spirit) {
                                LessonRowView(lesson: spirit)
                            }
                        }
                    }
                } header: {
                    LearnHeaderView(
                        text: "Spirits",
                        isCollapsed: $isBasicSpiritsCollapsed)
                }

                // MARK: ADVANCED SPIRITS
                Section {
                    if isAdvSpiritsCollapsed {
                        NavigationLink(value: viewModel.advancedSpirits[0]) {
                            LessonRowView(lesson: viewModel.advancedSpirits[0])
                        }
                    } else {
                        ForEach(viewModel.advancedSpirits, id: \.id) { lesson in
                            NavigationLink(value: lesson) {
                                LessonRowView(lesson: lesson)
                            }
                        }
                    }
                } header: {
                    LearnHeaderView(
                        text: "Advanced Spirits",
                        isCollapsed: $isAdvSpiritsCollapsed)
                }

                // MARK: LIQUEURS
                Section {
                    if isLiqueursCollapsed {
                        NavigationLink(value: viewModel.liqueurs[0]) {
                            LessonRowView(lesson: viewModel.liqueurs[0])
                        }
                    } else {
                        ForEach(viewModel.liqueurs, id: \.id) { lesson in
                            NavigationLink(value: lesson) {
                                LessonRowView(lesson: lesson)
                            }
                        }
                    }
                } header: {
                    LearnHeaderView(
                        text: "Liqueurs",
                        isCollapsed: $isLiqueursCollapsed)
                }

                // MARK: SYRUPS
                Section {
                    if isSyrupsCollapsed {
                        NavigationLink(value: viewModel.syrups[0]) {
                            LessonRowView(lesson: viewModel.syrups[0])
                        }
                    } else {
                        ForEach(viewModel.syrups) { syrup in
                            NavigationLink(value: syrup) {
                                LessonRowView(lesson: syrup)
                            }
                        }
                    }
                } header: {
                    LearnHeaderView(
                        text: "Syrups",
                        isCollapsed: $isSyrupsCollapsed)
                }

                // MARK: ADVANCED TECHNIQUES
                Section {
                    if isAdvTechniquesCollapsed {
                        NavigationLink(value: viewModel.advancedLessons[0]) {
                            LessonRowView(lesson: viewModel.advancedLessons[0])
                        }
                    } else {
                        ForEach(viewModel.advancedLessons) { lesson in
                            NavigationLink(value: lesson) {
                                LessonRowView(lesson: lesson)
                            }
                        }
                    }
                } header: {
                    LearnHeaderView(
                        text: "Advanced techniques",
                        isCollapsed: $isAdvTechniquesCollapsed)
                }

                // MARK: CALCULATORS
                Section {
                    ABVRowView()
                    if !isCalculatorsCollapsed {
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
                    if isBooksCollapsed {
                        NavigationLink(value: viewModel.books[0]) {
                            BookRowView(book: viewModel.books[0])
                        }
                    } else {
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
            .onAppear {
                if viewModel.advancedLessons.isEmpty {
                    viewModel.fetchLessons()
                    viewModel.fetchBooks()
                }
            }
            .refreshable {
                viewModel.refreshData()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#if DEBUG
#Preview {
    LearnView()
}
#endif
