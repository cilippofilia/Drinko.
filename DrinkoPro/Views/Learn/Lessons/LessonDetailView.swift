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
        ScrollView(.vertical, showsIndicators: false) {
            if sizeClass == .compact {
                compactLessonView
            } else {
                regularLessonView
            }
        }
        .navigationTitle(lesson.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    var compactLessonView: some View {
        VStack {
            if lesson.hasVideo {
                VideoView(videoID: lesson.videoID)
                    .frame(width: compactScreenWidth,
                           height: frameHeight)
                    .clipShape(
                        RoundedRectangle(cornerRadius: corners,
                                         style: .continuous))
            } else {
                AsyncImage(url: URL(string: lesson.img)) { phase in
                    switch phase {
                        case .failure:
                            imageFailedToLoad
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        default:
                            ProgressView()
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

                Text(lesson.body)
            }
            .frame(maxWidth: compactScreenWidth)
            .padding(.bottom)
        }
    }

    var regularLessonView: some View {
        VStack(spacing: 20) {
            AsyncImage(url: URL(string: lesson.img)) { phase in
                switch phase {
                    case .failure:
                        imageFailedToLoad
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        ProgressView()
                }
            }
            .frame(height: frameHeight * 1.75)
            .clipped()

            VStack(spacing: 20) {
                Text(lesson.title)
                    .font(.title.bold())

                Text(lesson.description)
                    .font(.headline)
                    .foregroundColor(.secondary)

                Text(lesson.body)
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
