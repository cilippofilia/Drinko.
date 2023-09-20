//
//  LearnRowView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 27/04/2023.
//

import SwiftUI

struct LearnRowView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @State private var rowHeight: CGFloat = 45
    @State private var corners: CGFloat = 10

    var lesson: Lesson

    var body: some View {
        NavigationLink(destination: LearnDetailView(lesson: lesson)) {
            HStack(spacing: sizeClass == .compact ? 10 : 20) {
                Image(lesson.img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: rowHeight, 
                           height: rowHeight)
                    .cornerRadius(corners)

                VStack(alignment: .leading) {
                    Text(lesson.title)
                        .font(.headline)

                    Text(lesson.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .truncationMode(.tail)
                }
            }
        }
        .frame(height: rowHeight)
    }
}

#Preview {
    LearnRowView(lesson: .example)
}
