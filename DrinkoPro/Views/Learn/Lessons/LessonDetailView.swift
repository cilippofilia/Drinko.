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

    var lesson: Lesson

    var body: some View {
        ScrollView {
            VStack {
                AsyncImageView(
                    image: lesson.image,
                    frameHeight: imageFrameHeight,
                    aspectRatio: .fill,
                    scalesWithContainer: true
                )

                VStack {
                    Text(lesson.title)
                        .font(.title.bold())

                    Text(lesson.description)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        #if os(macOS)
                        .multilineTextAlignment(.center)
                        #endif

                    VStack(alignment: .leading) {
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
                .padding([.horizontal, .bottom])
                .frame(maxWidth: 700)
                .frame(maxWidth: .infinity)
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
