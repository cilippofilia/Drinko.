//
//  LearnDetailView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 27/04/2023.
//

import SwiftUI

struct LearnDetailView: View {
    @Environment(\.openURL) var openURL
    var lesson: Lesson

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                if lesson.hasVideo {
                    VideoView(videoID: lesson.videoID)
                        .frame(width: screenWidthPlusMargins,
                               height: screenHeight * 0.3)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 10,
                                             style: .continuous)
                        )
                } else {
                    Image(lesson.img)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 280)
                        .clipped()
                }

                VStack(spacing: 10) {
                    Text(lesson.title)
                        .font(.title)
                        .bold()

                    Text(lesson.description)
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Text(lesson.body)
                }
                .frame(maxWidth: screenWidthPlusMargins)
                .padding(.bottom)
            }
        }
        .navigationTitle(lesson.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#if DEBUG
struct LearnDetailView_Previews: PreviewProvider {
    static var previews: some View {
        LearnDetailView(lesson: .example)
    }
}
#endif
