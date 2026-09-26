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

    private var isCompact: Bool { sizeClass == .compact }

    var body: some View {
        ScrollView {
            VStack(spacing: isCompact ? nil : 20) {
                AsyncImageView(
                    image: lesson.image,
                    frameHeight: imageFrameHeight,
                    aspectRatio: .fill
                )

                VStack(spacing: isCompact ? 10 : 20) {
                    Text(lesson.title)
                        .font(.title.bold())

                    Text(lesson.description)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        #if os(iOS)
                        .padding(.bottom, isCompact ? 0 : nil)
                        #elseif os(macOS)
                        .multilineTextAlignment(isCompact ? .leading : .center)
                        #endif

                    VStack(alignment: .leading, spacing: isCompact ? nil : 20) {
                        ForEach(lesson.body) { text in
                            VStack(alignment: .leading, spacing: isCompact ? 10 : nil) {
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
                .padding([.horizontal, .bottom])
            }
        }
        .navigationTitle(lesson.title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .scrollIndicators(.hidden, axes: .vertical)
        .scrollBounceBehavior(.basedOnSize)
    }
}

#if DEBUG
#Preview {
    LessonDetailView(lesson: .example)
}
#endif
