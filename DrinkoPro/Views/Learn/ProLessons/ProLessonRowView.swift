//
//  ProLessonRowView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 18/10/2023.
//

import SwiftUI

struct ProLessonRowView: View {
    @Environment(\.horizontalSizeClass) var sizeClass

    @State private var rowHeight: CGFloat = 45
    @State private var corners: CGFloat = 10

    var proLesson: ProLesson

    var body: some View {
        NavigationLink(destination: ProLessonDetailView(proLesson: proLesson)) {
            HStack(spacing: sizeClass == .compact ? 10 : 20) {
                Image(proLesson.img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: rowHeight,
                           height: rowHeight)
                    .cornerRadius(corners)

                VStack(alignment: .leading) {
                    Text(proLesson.title)
                        .font(.headline)

                    Text(proLesson.description)
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
    ProLessonRowView(proLesson: .sample)
}
