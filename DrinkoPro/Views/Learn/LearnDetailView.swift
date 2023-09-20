//
//  LearnDetailView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 27/04/2023.
//

import SwiftUI

struct LearnDetailView: View {
    @Environment(\.openURL) var openURL
    @Environment(\.horizontalSizeClass) var sizeClass
    
    @State private var frameHeight: CGFloat = 280
    @State private var corners: CGFloat = 10

    var lesson: Lesson

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            if sizeClass == .compact {
                compactLearnView
            } else {
                regularLearnView
            }
        }
        .navigationTitle(lesson.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    var compactLearnView: some View {
        VStack {
            if lesson.hasVideo {
                VideoView(videoID: lesson.videoID)
                    .frame(width: compactScreenWidth,
                           height: frameHeight)
                    .clipShape(
                        RoundedRectangle(cornerRadius: corners,
                                         style: .continuous))
            } else {
                Image(lesson.img)
                    .resizable()
                    .scaledToFill()
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

    var regularLearnView: some View {
        VStack(spacing: 20) {
            if lesson.hasVideo {
                VideoView(videoID: lesson.videoID)
                    .frame(width: regularScreenWidth)
                    .clipShape(
                        RoundedRectangle(cornerRadius: corners * 1.75,
                                         style: .continuous))
            } else {
                Image(lesson.img)
                    .resizable()
                    .scaledToFill()
                    .frame(height: frameHeight * 1.75)
                    .clipped()
            }

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

#Preview {
    LearnDetailView(lesson: .example)
}
