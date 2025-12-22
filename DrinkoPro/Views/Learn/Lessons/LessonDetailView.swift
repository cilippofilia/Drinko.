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
    var spacing: CGFloat {
        #if os(iOS)
        if sizeClass == .compact {
            return 10
        } else {
            return 20
        }
        #elseif os(macOS)
        return 10
        #endif
    }
    var body: some View {
        ScrollView {
            if sizeClass == .compact {
                compactLessonView
            } else {
                regularLessonView
            }
        }
        #if os(iOS)
        .navigationTitle(lesson.title)
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

            VStack(spacing: spacing) {
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
            .padding(.bottom)
            #elseif os(macOS)
            .padding([.horizontal, .bottom], 20)
            #endif
        }
    }

    var regularLessonView: some View {
        VStack {
            AsyncImageView(
                image: lesson.image,
                frameHeight: imageFrameHeight,
                aspectRatio: .fill
            )

            VStack(spacing: spacing) {
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
            #if os(iOS)
            .frame(width: screenWidth * 0.7)
            .padding(.bottom)
            #elseif os(macOS)
            .padding([.horizontal, .bottom], 30)
            #endif
        }
    }
}

#if DEBUG
#Preview {
    LessonDetailView(lesson: .example)
}
#endif
