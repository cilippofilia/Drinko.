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
            VStack(spacing: 10) {
                Image(lesson.img)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 280)
                    .clipped()

                VStack {
                    Text(lesson.title)
                        .font(.title)
                        .bold()
                        .padding(.vertical)

                    Text(lesson.description)
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Text(lesson.body)
                        .padding(.vertical)
                }
                .frame(maxWidth: screenWidthPlusMargins)
                .padding(.bottom)

                if lesson.hasVideo {
                    Button(action: {
                        openURL(URL(string: lesson.videoURL!)!)
                    }) {
                        DrinkoLabel(symbolName: "video.fill",
                                    text: "Go to Video",
                                    color: .white,
                                    background: .blue)
                    }
                }
            }
        }
        .navigationTitle(lesson.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LearnDetailView_Previews: PreviewProvider {
    static var previews: some View {
        LearnDetailView(lesson: .example)
    }
}
