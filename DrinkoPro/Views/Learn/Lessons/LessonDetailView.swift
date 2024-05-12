//
//  LessonDetailView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 27/04/2023.
//

import SwiftUI

struct LessonDetailView: View {
    @Environment(\.openURL) var openURL
    @Environment(\.horizontalSizeClass) var sizeClass
    
    @State private var frameHeight: CGFloat = 280
    @State private var corners: CGFloat = 10

    var lesson: Lesson

    var body: some View {
        ScrollView {
            if sizeClass == .compact {
                compactLessonView
            } else {
                regularLessonView
            }
        }
        .navigationTitle(lesson.title)
        .navigationBarTitleDisplayMode(.inline)
        .scrollIndicators(.hidden, axes: .vertical)
        .scrollBounceBehavior(.basedOnSize)
    }

    var compactLessonView: some View {
        VStack {
            if lesson.hasVideo ?? false {
                VideoView(videoID: lesson.videoID!)
                    .frame(width: compactScreenWidth,
                           height: frameHeight)
                    .clipShape(
                        RoundedRectangle(cornerRadius: corners,
                                         style: .continuous))
            } else {
                CachedImage(
                    url: lesson.img,
                    animation: .easeInOut,
                    transition: .opacity
                ) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()

                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        imageFailedToLoad

                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: frameHeight)
                .clipped()
            }

            VStack(spacing: 10) {
                Text(lesson.title)
                    .font(.title.bold())

                Text(lesson.description)
                    .font(.headline)
                    .foregroundColor(.secondary)

                VStack(alignment: .leading) {
                    ForEach(lesson.body) { text in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(text.heading)
                                .font(text.heading.count < 50 ? .headline : .body)
                            
                            if text.content != "" {
                                Text(text.content)
                            }
                        }
                        .padding(.vertical, 10)
                    }
                }
            }
            .frame(maxWidth: compactScreenWidth)
            .padding(.bottom)
        }
    }

    var regularLessonView: some View {
        VStack(spacing: 20) {
            if lesson.hasVideo ?? false {
                VideoView(videoID: lesson.videoID!)
                    .frame(width: compactScreenWidth,
                           height: frameHeight)
                    .clipShape(
                        RoundedRectangle(cornerRadius: corners,
                                         style: .continuous))
            } else {
                CachedImage(
                    url: lesson.img,
                    animation: .easeInOut,
                    transition: .opacity
                ) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        imageFailedToLoad

                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: frameHeight)
                .clipped()
            }

            VStack(spacing: 20) {
                Text(lesson.title)
                    .font(.title.bold())

                Text(lesson.description)
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
               
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(lesson.body) { text in
                        VStack(alignment: .leading) {
                            Text(text.heading)
                                .font(text.heading.count < 50 ? .headline : .body)

                            if text.content != "" {
                                Text(text.content)
                            }
                        }
                        .padding(.vertical, 10)
                    }
                }
            }
            .frame(maxWidth: regularScreenWidth)
            .padding(.bottom)
        }
    }
}

#if DEBUG
#Preview {
    LessonDetailView(lesson: .example)
}
#endif
