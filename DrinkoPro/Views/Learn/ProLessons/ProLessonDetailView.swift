//
//  ProLessonDetailView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 18/10/2023.
//

import SwiftUI

struct ProLessonDetailView: View {
    @Environment(\.openURL) var openURL
    @Environment(\.horizontalSizeClass) var sizeClass

    @State private var frameHeight: CGFloat = 280

    var proLesson: ProLesson

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                Image(proLesson.img)
                    .resizable()
                    .scaledToFill()
                    .frame(height: frameHeight)
                    .clipped()

                VStack(spacing: sizeClass == .compact ? 10 : 20) {
                    Text(proLesson.title)
                        .font(.title.bold())

                    Text(proLesson.description)
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Text(proLesson.body)
                }
                .frame(maxWidth: compactScreenWidth)
                .padding(.bottom)
            }
        }
        .navigationTitle(proLesson.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ProLessonDetailView(proLesson: .sample)
}
