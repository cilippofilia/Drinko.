//
//  LearnView.swift
//  DrinkoProMac
//
//  Created by Filippo Cilia on 24/05/2025.
//

import SwiftUI

struct LearnView: View {
    @State private var viewModel = LessonsViewModel()
    @State private var expandedSections: Set<String> = []
    @State private var selectedLesson: Lesson?

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedLesson) {
                ForEach(viewModel.topics, id: \.self) { topic in
                    DisclosureGroup(
                        isExpanded: Binding(
                            get: { expandedSections.contains(topic) },
                            set: { isExpanded in
                                if isExpanded {
                                    expandedSections.insert(topic)
                                } else {
                                    expandedSections.remove(topic)
                                }
                            }
                        )
                    ) {
                        ForEach(viewModel.getLessons(for: topic)) { lesson in
                            NavigationLink(value: lesson) {
                                Text(lesson.title)
                                    .tag(lesson)
                                    .contentShape(Rectangle())
                            }
                        }
                    } label: {
                        DisclosureLabelView(topic: topic)
                    }
                }
            }
        } detail: {
            if let lesson = selectedLesson {
                LessonDetailView(lesson: lesson)
            } else {
                UnselectedView(
                    image: "book.fill",
                    title: "Welcome to Drinko Learn",
                    subtitle: "Select a lesson from the sidebar to get started."
                )
            }
        }
        .navigationDestination(for: Lesson.self) { lesson in
            VStack(alignment: .leading, spacing: 10) {
                Text(lesson.title)
                    .font(.title)
                    .bold()
                Text(lesson.description)
                    .font(.body)
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    LearnView()
}
