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

    var body: some View {
        @Bindable var lessonsVM = lessonsViewModel

        NavigationSplitView {
            List(lessonsVM.allLessons, selection: $selectedLesson) { lesson in
                HStack {
                    Image(systemName: "book.pages") // replace with lesson image
                    VStack(alignment: .leading) {
                        Text(lesson.title)
                        Text(lesson.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .tag(lesson)
            }
        } detail: {
            if let lesson = selectedLesson {
                VStack(alignment: .center) {
                    Text(lesson.title)
                        .font(.title2)
                        .bold()
                    Text(lesson.description)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .multilineTextAlignment(.center)
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
