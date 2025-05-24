//
//  LearnMacView.swift
//  DrinkoProMac
//
//  Created by Filippo Cilia on 24/05/2025.
//

import SwiftUI

struct LearnMacView: View {
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
                        Text(topic.capitalized.replacingOccurrences(of: "-", with: " "))
                    }
                }
            }
        } detail: {
            if let lesson = selectedLesson {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        AsyncImage(url: URL(string: lesson.image)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image.resizable().scaledToFit().cornerRadius(8)
                            case .failure:
                                Image(systemName: "photo").resizable().scaledToFit().foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(height: 200)

                        Text(lesson.title)
                            .font(.largeTitle)
                            .bold()
                        Text(lesson.description)
                            .font(.title2)
                            .foregroundStyle(.secondary)

                        if !lesson.body.isEmpty {
                            Divider()
                            ForEach(lesson.body) { content in
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(content.heading)
                                        .font(.headline)
                                    Text(content.content)
                                        .font(.body)
                                }
                            }
                        }

                        Spacer()
                    }
                    .padding()
                }
            } else {
                VStack(alignment: .center, spacing: 16) {
                    Spacer()
                    Image(systemName: "book.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundStyle(.blue)
                    Text("Welcome to Drinko Learn")
                        .font(.largeTitle)
                        .bold()
                    Text("Select a lesson from the sidebar to get started.")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
                .multilineTextAlignment(.center)
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
        .frame(minWidth: 750, minHeight: 400)
    }
}

#Preview {
    LearnMacView()
}
