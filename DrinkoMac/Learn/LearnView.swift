//
//  LearnView.swift
//  DrinkoMac
//
//  Created by Filippo Cilia on 18/12/2025.
//

import SwiftUI

struct LearnView: View {
    static let learnTag: String? = "Learn"
    @Environment(LessonsViewModel.self) private var lessonsViewModel
    @State private var selectedLesson: Lesson?
    @State private var selectedTopic: String?

    var body: some View {
        @Bindable var lessonsVM = lessonsViewModel

        NavigationSplitView {
            List(
                lessonsVM.topics,
                id: \.self,
                selection: $selectedTopic
            ) { topic in
                Text(topic.replacing("-", with: " ").capitalizingFirstLetter())
                    .tag(topic)
            }
        } content: {
            if let topic = selectedTopic {
                List(
                    lessonsVM.getLessons(for: topic),
                    selection: $selectedLesson
                ) { lesson in
                    LessonRowView(lesson: lesson)
                        .tag(lesson)
                }
            } else {
                ContentUnavailableView(
                    "No Topic Selected",
                    systemImage: "book.closed",
                    description: Text("Select a topic from the list to view all the lessons related to it.")
                )
            }
        } detail: {
            // Detail lesson view
            if let lesson = selectedLesson {
                LessonDetailView(lesson: lesson)
                    .tag(lesson)
            } else {
                ContentUnavailableView(
                    "No Lesson Selected",
                    systemImage: "book.closed",
                    description: Text("Select a lesson from the list to view its details")
                )
            }
        }
    }
}

#Preview {
    LearnView()
        .environment(LessonsViewModel())
}

