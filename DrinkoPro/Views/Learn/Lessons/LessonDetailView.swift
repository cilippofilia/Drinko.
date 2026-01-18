//
//  LessonDetailView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 27/04/2023.
//

import AVKit
import SwiftUI

struct LessonDetailView: View {
    @Environment(\.openURL) var openURL
    @Environment(\.horizontalSizeClass) var sizeClass

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
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .scrollIndicators(.hidden, axes: .vertical)
        .scrollBounceBehavior(.basedOnSize)
    }

    var compactLessonView: some View {
        VStack {
            AsyncImageView(
                image: lesson.image,
                frameHeight: imageFrameHeight,
                aspectRatio: .fill
            )

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
            #if os(iOS)
            .frame(width: screenWidth * 0.9)
            #elseif os(macOS)
            .padding(.horizontal)
            #endif
            .padding(.bottom)
        }
    }

    var regularLessonView: some View {
        VStack(spacing: 20) {
            AsyncImageView(
                image: lesson.image,
                frameHeight: imageFrameHeight,
                aspectRatio: .fill
            )

            VStack(spacing: 20) {
                Text(lesson.title)
                    .font(.title.bold())

                Text(lesson.description)
                    .font(.headline)
                    .foregroundColor(.secondary)
                    #if os(iOS)
                    .padding(.bottom)
                    #elseif os(macOS)
                    .multilineTextAlignment(.center)
                    #endif

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
            #if os(iOS)
            .frame(width: screenWidth * 0.7)
            #elseif os(macOS)
            .padding(.horizontal)
            #endif
            .padding(.bottom)
        }
    }
}

#if DEBUG
#Preview {
    LessonDetailView(lesson: .example)
}
#endif
