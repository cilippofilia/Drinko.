//
//  LessonDetailView.swift
//  DrinkoProMac
//
//  Created by Filippo Cilia on 24/05/2025.
//

import SwiftUI

struct LessonDetailView: View {
    let lesson: Lesson

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 16) {
                AsyncImageView(
                    image: lesson.image,
                    frameHeight: imageFrameHeight,
                    aspectRatio: .fit
                )
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                Text(lesson.title)
                    .font(.largeTitle)
                    .bold()

                Text(lesson.description)
                    .font(.title2)
                    .foregroundStyle(.secondary)

                if !lesson.body.isEmpty {
                    Divider()
                    ForEach(lesson.body) { content in
                        VStack(alignment: .leading) {
                            Text(content.heading)
                                .font(.headline)
                            Text(content.content)
                        }
                    }
                }

                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    LessonDetailView(lesson: Lesson.example)
}
