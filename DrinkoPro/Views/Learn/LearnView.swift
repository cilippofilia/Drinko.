//
//  LearnView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 22/04/2023.
//

import SwiftUI

struct LearnView: View {
    static let learnTag: String? = "Learn"
    @State private var viewModel = AdvancedLesson()
    
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
                        LessonRowView(lesson: viewModel.basicLessons[0])
                    } else {
                        ForEach(viewModel.basicLessons, id: \.id) { lesson in
                            LessonRowView(lesson: lesson)
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
                        LessonRowView(lesson: viewModel.barPreps[0])
                    } else {
                        ForEach(viewModel.barPreps, id: \.id) { lesson in
                            LessonRowView(lesson: lesson)
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
                        LessonRowView(lesson: viewModel.spirits[0])
                    } else {
                        ForEach(viewModel.spirits) { spirit in
                            LessonRowView(lesson: spirit)
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
                        LessonRowView(lesson: viewModel.advancedSpirits[0])
                    } else {
                        ForEach(viewModel.advancedSpirits, id: \.id) { lesson in
                            LessonRowView(lesson: lesson)
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
                        LessonRowView(lesson: viewModel.liqueurs[0])
                    } else {
                        ForEach(viewModel.liqueurs, id: \.id) { lesson in
                            LessonRowView(lesson: lesson)
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
                        LessonRowView(lesson: viewModel.syrups[0])
                    } else {
                        ForEach(viewModel.syrups) { syrup in
                            LessonRowView(lesson: syrup)
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
                        LessonRowView(lesson: viewModel.advancedLessons[0])
                    } else {
                        ForEach(viewModel.advancedLessons) { lesson in
                            LessonRowView(lesson: lesson)
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
                        BookRowView(book: viewModel.books[0])
                    } else {
                        ForEach(viewModel.books) { book in
                            BookRowView(book: book)
                        }
                    }
                } header: {
                    LearnHeaderView(
                        text: "Books",
                        isCollapsed: $isBooksCollapsed)
                }
            }
            .navigationTitle("Learn")
            .onAppear {
                if viewModel.advancedLessons.isEmpty {
                    viewModel.fetchAdvancedLessons()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    LearnView()
}


/*
 TODO: MOVE ALL THE JSONS ONLINE
 TODO: NEED TO IMPLEMENT THIS
 TODO: CACHE LOADED JSONS
 
 ForEach(viewModel.topics, id:\.self) { topic in
     Section {

     } header: {
         LearnHeaderView(text: topic.replacingOccurrences(of: "-", with: " "), isCollapsed: .constant(true))
     }
 }
*/
