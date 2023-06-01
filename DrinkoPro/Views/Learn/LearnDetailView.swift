//
//  LearnDetailView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 27/04/2023.
//

import SwiftUI

struct LearnDetailView: View {
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
