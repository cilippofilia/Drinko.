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
            if sizeClass == .compact {
                compactRowView
            } else {
                regularRowView
            }
        }
        .frame(height: sizeClass == .compact ? rowHeight : rowHeight * 1.75)
    }

    var compactRowView: some View {
        HStack {
            Image(lesson.img)
                .resizable()
                .scaledToFill()
                .frame(width: rowHeight, height: rowHeight)
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

    var regularRowView: some View {
        HStack(spacing: 20) {
            Image(lesson.img)
                .resizable()
                .scaledToFill()
                .frame(width: rowHeight * 1.75, height: rowHeight * 1.75)
                .cornerRadius(corners * 1.75)

            VStack(alignment: .leading) {
                Text(lesson.title)
                    .font(.title.bold())

                Text(lesson.description)
                    .font(.system(.headline,
                                  design: .default,
                                  weight: .semibold))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .truncationMode(.tail)
            }
        }
    }
}

#Preview {
    LearnRowView(lesson: .example)
}
